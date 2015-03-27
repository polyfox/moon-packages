module Moon #:nodoc:
  class Cuboid
    include Serializable
    include Serializable::Properties

    # @return [Integer]
    property_accessor :x
    # @return [Integer]
    property_accessor :y
    # @return [Integer]
    property_accessor :z
    # @return [Integer]
    property_accessor :w
    # @return [Integer]
    property_accessor :h
    # @return [Integer]
    property_accessor :d

    # @overload initialize(cuboid)
    #   @param [Cuboid] cuboid
    # @overload initialize(num)
    #   @param [Integer] num
    # @overload initialize(options)
    #   @param [Hash] options
    # @overload initialize(position, size)
    #   @param [Vector3] position
    #   @param [Vector3] size
    # @overload initialize(x, y, z, w, h, d)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] z
    #   @param [Integer] w
    #   @param [Integer] h
    #   @param [Integer] d
    def initialize(*args)
      clear
      set(*args) unless args.empty?
    end

    ##
    # @return [Integer]
    def x2
      @x + @w
    end

    ##
    # @return [Integer]
    def y2
      @y + @h
    end

    ##
    # @return [Integer]
    def z2
      @z + @d
    end

    ##
    # @return [Array<Integer>[6]]
    def to_a
      return @x, @y, @z, @w, @h, @d
    end

    ##
    # @return [Hash<Symbol, Integer>]
    def to_h
      { x: @x, y: @y, z: @z, w: @w, h: @h, d: @d }
    end

    ##
    # @return [Rect]
    def to_rect_xy
      Moon::Rect.new(@x, @y, @w, @h)
    end

    ##
    # @return [Rect]
    def to_rect_xz
      Moon::Rect.new(@x, @z, @w, @d)
    end

    ##
    # @return [Rect]
    def to_rect_yz
      Moon::Rect.new(@y, @z, @h, @d)
    end

    ##
    # @return [self]
    def clear
      @x, @y, @z, @w, @h, @d = 0, 0, 0, 0, 0, 0
      self
    end

    def set(*args)
      @x, @y, @z, @w, @h, @d = *self.class.extract(args.singularize)
      self
    end

    # @return [Vector3]
    def position
      Vector3.new @x, @y, @z
    end

    # Moves the Cuboid to the given position
    #
    # @overload position=(x, y, z)
    #   @param [Float] x
    #   @param [Float] y
    #   @param [Float] z
    # @overload position=(position)
    #   @param [Vector3] position
    def position=(other)
      @x, @y, @z = *Vector3.extract(other)
      self
    end

    ##
    # @overload resize(vec3)
    #   @param [Vector3] vec3
    # @overload resize(w, h, d)
    #   @param [Integer] w
    #   @param [Integer] h
    #   @param [Integer] d
    # @overload resize(hash)
    #   @param [Hash<Symbol, Integer>]
    # @return [self]
    def resize(*args)
      @w, @h, @d = *Vector3.extract(args.singularize)
      self
    end

    ##
    # @overload contains?(vec3)
    #   @param [Vector3] vec3
    # @overload contains?(x, y, z)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] z
    # @return [Boolean]
    def contains?(*args)
      x, y, z = *Vector3.extract(args.singularize)
      x.between?(self.x, self.x2 - 1) &&
      y.between?(self.y, self.y2 - 1) &&
      z.between?(self.z, self.z2 - 1)
    end

    ##
    # @return [Boolean]
    def empty?
      return w == 0 && h == 0 && d == 0
    end

    ##
    # @return [Vector2]
    def xy
      Vector2.new @x, @y
    end

    ##
    # @param [Vector2] vec2
    def xy=(vec2)
      @x, @y = *Vector2.extract(vec2)
    end

    ##
    # @return [Vector3]
    def xyz
      Vector3.new @x, @y, @z
    end

    ##
    # @param [Vector3] vec3
    def xyz=(vec3)
      @x, @y, @z = *Vector3.extract(vec3)
    end

    ##
    # @return [Vector2]
    def wh
      Vector2.new @w, @h
    end

    ##
    # @param [Vector2] vec2
    def wh=(vec2)
      @w, @h = *Vector2.extract(vec2)
    end

    ##
    # @return [Vector3]
    def whd
      Vector3.new @w, @h, @d
    end

    ##
    # @param [Vector3] vec3
    def whd=(vec3)
      @w, @h, @d = *Vector3.extract(vec3)
    end

    ##
    # Converts a given Object to Cuboid array
    # @param [Object] obj
    # @return [Array<Numeric>] (x, y, z, w, h, d)
    def self.extract(obj)
      case obj
      when Array
        case obj.size
        when 2
          pos, size = *obj
          x, y, z = *Vector3.extract(pos)
          w, h, d = *Vector3.extract(size)
          return x, y, z, w, h, d
        when 6
          return *obj
        else
          raise ArgumentError, "expected Array of size 2 or 6" if obj.size != 6
        end
      when Moon::Cuboid
        return *obj
      when Hash
        if obj.key?(:position)
          pos  = obj.fetch(:position)
          size = obj.fetch(:size)
          x, y, z = *Vector3.extract(pos)
          w, h, d = *Vector3.extract(size)
          return x, y, z, w, h, d
        else
          return obj.fetch_multi(:x, :y, :z, :w, :h, :d)
        end
      when Numeric
        return 0, 0, 0, obj, obj, obj
      when Moon::Vector3
        return 0, 0, 0, *obj
      else
        raise TypeError,
              "wrong argument type #{obj.class} (expected Array, Cuboid, Hash, Numeric, Vector3)"
      end
    end

    def self.[](*objs)
      obj = objs.size == 1 ? objs.first : objs
      new(*extract(obj))
    end

    alias :position :xyz
    alias :size :whd
  end
end
