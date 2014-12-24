module Moon #:nodoc:
  class Cuboid
    # @return [Integer]
    attr_accessor :x
    # @return [Integer]
    attr_accessor :y
    # @return [Integer]
    attr_accessor :z
    # @return [Integer]
    attr_accessor :width
    # @return [Integer]
    attr_accessor :height
    # @return [Integer]
    attr_accessor :depth

    alias :w :width
    alias :w= :width=
    alias :h :height
    alias :h= :height=
    alias :d :depth
    alias :d= :depth=

    # @overload initialize(cuboid)
    #   @param [Cuboid] cuboid
    # @overload initialize(num)
    #   @param [Integer] num
    # @overload initialize(options)
    #   @param [Hash] options
    # @overload initialize(position, size)
    #   @param [Vector3] position
    #   @param [Vector3] size
    # @overload initialize(x, y, z, width, height, depth)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] z
    #   @param [Integer] width
    #   @param [Integer] height
    #   @param [Integer] depth
    def initialize(*args)
      clear
      set(*args) unless args.empty?
    end

    ##
    # @return [Integer]
    def x2
      @x + @width
    end

    ##
    # @return [Integer]
    def y2
      @y + @height
    end

    ##
    # @return [Integer]
    def z2
      @z + @depth
    end

    ##
    # @return [Array<Integer>[6]]
    def to_a
      return @x, @y, @z, @width, @height, @depth
    end

    ##
    # @return [Hash<Symbol, Integer>]
    def to_h
      { x: @x, y: @y, z: @z, width: @width, height: @height, depth: @depth }
    end

    ##
    # @return [Rect]
    def to_rect_xy
      Moon::Rect.new(@x, @y, @width, @height)
    end

    ##
    # @return [Rect]
    def to_rect_xz
      Moon::Rect.new(@x, @z, @width, @depth)
    end

    ##
    # @return [Rect]
    def to_rect_yz
      Moon::Rect.new(@y, @z, @height, @depth)
    end

    ##
    # @return [self]
    def clear
      @x, @y, @z, @width, @height, @depth = 0, 0, 0, 0, 0, 0
      self
    end

    def set(*args)
      @x, @y, @z, @width, @height, @depth = *self.class.extract(args.singularize)
      self
    end

    def move(*args)
      @x, @y, @z = *Vector3.extract(args.singularize)
      self
    end

    ##
    # @overload resize(vec3)
    #   @param [Vector3] vec3
    # @overload resize(width, height, depth)
    #   @param [Integer] width
    #   @param [Integer] height
    #   @param [Integer] depth
    # @overload resize(hash)
    #   @param [Hash<Symbol, Integer>]
    # @return [self]
    def resize(*args)
      @width, @height, @depth = *Vector3.extract(args.singularize)
      self
    end

    ##
    # @overload inside?(vec3)
    #   @param [Vector3] vec3
    # @overload inside?(x, y, z)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] z
    # @return [Boolean]
    def inside?(*args)
      x, y, z = *Vector3.extract(args.singularize)
      x.between?(self.x, self.x2-1) &&
      y.between?(self.y, self.y2-1) &&
      z.between?(self.z, self.z2-1)
    end

    ##
    # @return [Boolean]
    def empty?
      return width == 0 && height == 0 && depth == 0
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
      Vector2.new @width, @height
    end

    ##
    # @param [Vector2] vec2
    def wh=(vec2)
      @width, @height = *Vector2.extract(vec2)
    end

    ##
    # @return [Vector3]
    def whd
      Vector3.new @width, @height, @depth
    end

    ##
    # @param [Vector3] vec3
    def whd=(vec3)
      @width, @height, @depth = *Vector3.extract(vec3)
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
          return obj.fetch_multi(:x, :y, :z, :width, :height, :depth)
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
