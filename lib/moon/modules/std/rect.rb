module Moon
  class Rect
    include Serializable

    alias :w :width
    alias :w= :width=
    alias :h :height
    alias :h= :height=

    alias :initialize_xywh :initialize
    def initialize(*args)
      if args.empty?
        initialize_xywh(0, 0, 0, 0)
      else
        initialize_xywh(*args)
      end
    end

    def inside?(obj)
      x, y = *Vector2.extract(obj)
      x.between?(self.x, self.x2-1) && y.between?(self.y, self.y2-1)
    end

    def clear
      self.x = 0
      self.y = 0
      self.w = 0
      self.h = 0
      self
    end

    def empty?
      return width == 0 && height == 0
    end

    def &(other)
      nx  = x < other.x ? other.x : x
      ny  = y < other.y ? other.y : y
      nx2 = x2 < other.x2 ? x2 : other.x2
      ny2 = y2 < other.y2 ? y2 : other.y2
      Rect.new nx, ny, nx2 - nx, ny2 - ny
    end

    def set(*args)
      self.x, self.y, self.w, self.h = *Rect.extract(args.size > 1 ? args : args.first)
    end

    def to_s
      "#{x},#{y},#{w},#{h}"
    end

    def inspect
      "<#{self.class}: x=#{x} y=#{y} w=#{w} h=#{h}>"
    end

    def to_a
      [x, y, width, height]
    end

    def to_h
      { x: x, y: y, width: width, height: height }
    end

    def serialization_properties(&block)
      to_h.each(&block)
    end

    ##
    # @param [String] key
    # @value [Integer] value
    def set_property(key, value)
      case key.to_s
      when 'x'           then self.x = value
      when 'y'           then self.y = value
      when 'w', 'width'  then self.w = value
      when 'h', 'height' then self.h = value
      else
        raise KeyError, "no property named #{key}"
      end
    end

    def x2
      x + width
    end

    def x2=(x2)
      self.x = x2 - width
    end

    def y2
      y + height
    end

    def y2=(y2)
      self.y = y2 - height
    end

    def xy
      Vector2.new x, y
    end

    def xy=(other)
      self.x, self.y = *Vector2.extract(other)
    end

    def xyz
      Vector3.new x, y, 0
    end

    def xyz=(other)
      self.x, self.y, _ = *Vector3.extract(other)
    end

    def wh
      Vector2.new width, height
    end

    def wh=(other)
      self.w, self.h = *Vector2.extract(other)
    end

    def whd
      Vector3.new width, height, 0
    end

    def whd=(other)
      self.w, self.h, _ = *Vector3.extract(other)
    end

    ###
    # Extracts Rect related arguments from the given Object (obj)
    # @param [Object] obj
    def self.extract(obj)
      case obj
      when Array
        case obj.size
        when 2
          return [*Vector2.extract(obj[0]), *Vector2.extract(obj[1])]
        # x, y, w, h
        when 4
          return *obj
        else
          raise ArgumentError,
                "wrong Array size #{obj.size} (expected 1, 2 or 4)"
        end
      when Hash
        return obj.fetch_multi(:x, :y, :width, :height)
      when Numeric
        return 0, 0, obj, obj
      when Moon::Rect
        return *obj
      when Moon::Vector2
        return 0, 0, *obj
      else
        raise TypeError,
              "wrong argument type #{obj.class.inspect} (expected Array, Hash, Numeric, Rect or Vector2)"
      end
    end

    def self.[](*objs)
      obj = objs.size == 1 ? objs.first : objs
      new(*extract(obj))
    end

    alias :position :xy
    alias :size :wh
  end
end
