module Moon #:nodoc:
  class Rect
    module Cast
      def self.extract_array(obj)
        case obj.size
        # v2, v2
        when 2 then [*Vector2.extract(obj[0]), *Vector2.extract(obj[1])]
        # x, y, w, h
        when 4 then obj.to_a
        else
          raise ArgumentError,
                "wrong Array size #{obj.size} (expected 1, 2 or 4)"
        end
      end

      def self.extract(obj)
        case obj
        when Array   then extract_array(obj)
        when Hash    then obj.fetch_multi(:x, :y, :w, :h)
        when Numeric then return 0, 0, obj, obj
        when Rect    then obj.to_a
        when Vector2 then return 0, 0, *obj
        when Vector4 then obj.to_a
        else
          raise TypeError,
                "wrong argument type #{obj.class.inspect} (expected Array, Hash, Numeric, Rect or Vector2)"
        end
      end
    end

    include Serializable
    include Serializable::Properties

    property :x
    property :y
    property :w
    property :h

    alias :initialize_xywh :initialize
    def initialize(*args)
      if args.empty?
        initialize_xywh 0, 0, 0, 0
      else
        initialize_xywh(*args)
      end
    end

    # Splits the current rect into 4 sub rects of half size
    # @return [Array[4]<Moon::Rect>]
    def split
      sw = (w / 2.0).round
      sh = (h / 2.0).round
      return Rect.new(x + sw, y, sw, sh),
        Rect.new(x, y, sw, sh),
        Rect.new(x, y + sh, sw, sh),
        Rect.new(x + sw, y + sh, sw, sh)
    end

    def contains?(*args)
      x, y = *Vector2.extract(args.singularize)
      x.between?(self.x, self.x2 - 1) && y.between?(self.y, self.y2 - 1)
    end

    def clear
      self.x = 0
      self.y = 0
      self.w = 0
      self.h = 0
      self
    end

    def empty?
      return w == 0 && h == 0
    end

    def &(other)
      nx  = [x, other.x].max
      ny  = [y, other.y].max
      Rect.new nx, ny, [x2, other.x2].min - nx, [y2, other.y2].min - ny
    end

    def set(*args)
      self.x, self.y, self.w, self.h = *Rect.extract(args.singularize)
    end

    # Creates a new Rect from the current translated by the given position
    def translate(*args)
      r = Rect.new x, y, w, h
      r.position += args.singularize
      r
    end

    def translatef(*args)
      r = Rect.new x, y, w, h
      r.position += Vector2[args.singularize] * r.resolution
      r
    end

    def scale(*args)
      r = Rect.new x, y, w, h
      r.resolution = Vector2[args.singularize] * r.resolution
      r
    end

    def to_s
      "#{x},#{y},#{w},#{h}"
    end

    def to_a
      [x, y, w, h]
    end

    def to_h
      { x: x, y: y, w: w, h: h }
    end

    def property_get(key)
      send key
    end

    #
    # @param [String] key
    # @param [Integer] value
    def property_set(key, value)
      send "#{key}=", value
    end

    def x2
      x + w
    end

    def x2=(x2)
      self.x = x2 - w
    end

    def y2
      y + h
    end

    def y2=(y2)
      self.y = y2 - h
    end

    def position
      Vector2.new x, y
    end
    alias :xy :position

    def position=(other)
      self.x, self.y = *Vector2.extract(other)
    end
    alias :xy= :position=

    def xyz
      Vector3.new x, y, 0
    end

    def xyz=(other)
      self.x, self.y, _ = *Vector3.extract(other)
    end

    def resolution
      Vector2.new w, h
    end
    alias :wh :resolution

    def resolution=(other)
      self.w, self.h = *Vector2.extract(other)
    end
    alias :wh= :resolution=

    def whd
      Vector3.new w, h, 0
    end

    def whd=(other)
      self.w, self.h, _ = *Vector3.extract(other)
    end

    # Extracts Rect related arguments from the given Object (obj)
    #
    # @param [Object] obj
    # @return [Array<Integer>]
    def self.extract(obj)
      Cast.extract(obj)
    end

    def self.[](*objs)
      obj = objs.size == 1 ? objs.first : objs
      new(*extract(obj))
    end

    alias :position :xy
    alias :size :wh
  end
end