require 'std/core_ext/array'
require 'std/vector2'
require 'moon-serializable/load'

module Moon
  class Rect
    # Helper module for converting objects to Rect parameters [x, y, w, h]
    module Cast
      # Expands an Array as Rect parameters
      #
      # @param [Array] obj
      # @return [Array<Integer>] rect_parameters [x, y, w, h]
      def self.extract_array(obj)
        case obj.size
        # v2, v2
        when 2 then [*Vector2.extract(obj[0]), *Vector2.extract(obj[1])]
        # x, y, w, h
        when 4 then obj.to_a
        else
          raise ArgumentError,
                "wrong Array size #{obj.size} (expected 2 or 4)"
        end
      end

      # Attempts to extrat the Rect parameters from the obj
      #
      # @param [Object] obj
      # @return [Array<Integer>]
      def self.try_extract(obj)
        case obj
        when Array   then extract_array(obj)
        when Hash    then obj.fetch_multi(:x, :y, :w, :h)
        when Numeric then return 0, 0, obj, obj
        when Rect    then obj.to_a
        when Vector2 then return 0, 0, *obj
        when Vector4 then obj.to_a
        else
          nil
        end
      end

      # Extracts Rect like parameters from the given object
      #
      # @param [Object] obj
      # @return [Array<Integer>]
      def self.extract(obj)
        if result = try_extract(obj)
          return result
        elsif obj.respond_to?(:to_rect) && (rect = try_extract(obj.to_rect))
          return rect
        else
          raise TypeError,
                "wrong argument type #{obj.class.inspect} (expected Array, Hash, Numeric, Rect or Vector2)"
        end
      end
    end

    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
    add_property :w
    add_property :h

    # Splits the current Rect into 4 sub rects of half its original size
    #
    # @return [Array<Moon::Rect>[4]]
    def split
      sw = (w / 2.0).round
      sh = (h / 2.0).round
      return Rect.new(x, y, sw, sh),
        Rect.new(x + sw, y, sw, sh),
        Rect.new(x, y + sh, sw, sh),
        Rect.new(x + sw, y + sh, sw, sh)
    end

    # Determines if the Rect contains the given position within its space
    #
    # @param [Object] args  a vector2 like object or parameters
    # @return [Boolean]
    def contains?(*args)
      x, y = *Vector2.extract(args.singularize)
      x.between?(self.x, self.x2 - 1) && y.between?(self.y, self.y2 - 1)
    end

    # Determines if the Rect is empty, an empty rect either its width or
    # height as 0
    #
    # @return [Boolean]
    def empty?
      w == 0 || h == 0
    end

    # Calculates the intersection between 2 rects
    #
    # @param [Array<Integer>, Rect] other
    # @return [Rect]
    def &(other)
      ox, oy, ow, oh = *other
      nx  = [x, ox].max
      ny  = [y, oy].max
      Rect.new nx, ny, [x2, ox + ow].min - nx, [y2, oy + oh].min - ny
    end

    # Sets the Rect's properties from the given args
    #
    # @param [Object] args  can be variable number of
    # @return [self]
    def set(*args)
      self.x, self.y, self.w, self.h = *Rect.extract(args.singularize)
      self
    end

    # Creates a new Rect from the current translated by the given position
    #
    # @overload translate(tx, ty)
    #   @param [Integer] tx
    #   @param [Integer] ty
    # @return [Rect]
    def translate(*args)
      r = Rect.new x, y, w, h
      r.position += Vector2[args.singularize]
      r
    end

    # Same as translate, however the provided position will be scaled against
    # the Rect's resolution
    #
    # @overload translatef(tx, ty)
    #   @param [Float] tx
    #   @param [Float] ty
    # @return [Rect]
    def translatef(*args)
      r = Rect.new x, y, w, h
      r.position += r.resolution * Vector2[args.singularize]
      r
    end

    # Scales the Rect's resolution by the given amount
    #
    # @overload scale(sx, sy)
    #   @param [Float] sx
    #   @param [Float] sy
    # @return [Rect]
    def scale(*args)
      r = Rect.new x, y, w, h
      r.resolution = r.resolution * Vector2[args.singularize]
      r
    end

    # @return [Hash<Symbol, Integer>]
    def to_h
      { x: x, y: y, w: w, h: h }
    end

    # Returns the right `x` of the Rect
    #
    # @return [Integer]
    def x2
      x + w
    end

    # Set's
    # @param [Integer] x2
    def x2=(x2)
      self.x = x2 - w
    end

    # Returns the bottom `y` of the Rect
    #
    # @return [Integer]
    def y2
      y + h
    end

    # @param [Integer] y2
    def y2=(y2)
      self.y = y2 - h
    end

    # The Rect's (x, y) as a Vector2
    #
    # @return [Vector2]
    def position
      Vector2.new x, y
    end

    # Sets the Rect's position from the given vector like object
    #
    # @param [Object] other  vector2 like object
    def position=(other)
      self.x, self.y = *Vector2.extract(other)
    end

    # The Rect's (w, h) as a Vector2
    #
    # @return [Vector2]
    def resolution
      Vector2.new w, h
    end

    # Sets the Rect's resolution from the given vector like object
    #
    # @param [Object] other  vector2 like object
    def resolution=(other)
      self.w, self.h = *Vector2.extract(other)
    end

    # Extracts Rect related properties from the given Object (obj).
    # The Array returned contains [x, y, w, h]
    #
    # @param [Object] obj
    # @return [Array<Integer>]
    def self.extract(obj)
      Cast.extract(obj)
    end

    # Casts the object to a Rect
    # If the object is already a Rect, it is returned instead.
    #
    # @param [Object] objs
    # @return [Rect]
    def self.[](*objs)
      obj = objs.singularize
      if obj.is_a?(Rect)
        return obj
      else
        new(*extract(obj))
      end
    end
  end
end
