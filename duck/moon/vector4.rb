module Moon
  class Vector4 < Moon::DataModel::Metal
    field :x,      type: Numeric, default: 0.0
    field :y,      type: Numeric, default: 0.0
    field :z,      type: Numeric, default: 0.0
    field :w,      type: Numeric, default: 0.0

    alias :r :x
    alias :r= :x=
    alias :g :y
    alias :g= :y=
    alias :b :z
    alias :b= :z=
    alias :a :w
    alias :a= :w=

    def initialize(*args, &block)
      set(*args, &block)
    end

    def to_a
      return x, y, z, w
    end

    alias :dm_set :set
    def set(*args, &block)
      case args.size
      when 1
        dm_set args.first, &block
      when 4
        x, y, z, w = *args
        dm_set x: x, y: y, z: z, w: w, &block
      else
        dm_set x: 0.0, y: 0.0, z: 0.0, w: 0.0, &block
      end
    end

    def +(other)
      ox, oy, oz, ow = *self.class.extract(other)
      self.class.new(x + ox, y + oy, z + oz, w + ow)
    end

    def -(other)
      ox, oy, oz, ow = *self.class.extract(other)
      self.class.new(x - ox, y - oy, z - oz, w - ow)
    end

    def *(other)
      ox, oy, oz, ow = *self.class.extract(other)
      self.class.new(x * ox, y * oy, z * oz, w * ow)
    end

    def /(other)
      ox, oy, oz, ow = *self.class.extract(other)
      self.class.new(x / ox, y / oy, z / oz, w / ow)
    end

    def -@
      self.class.new(-x, -y, -z, -w)
    end

    def self.extract(obj)
      case obj
      when Numeric
        return obj, obj, obj, obj
      when Vector4
        return *obj
      when Array
        case obj.size
        when 1
          x, y, z = *obj.first
        when 2, 3
          params = []
          for item in obj
            case item
            when Numeric
              params << item
            when Vector2
              params.concat(obj.to_a)
            when Vector3
              params.concat(obj.to_a)
            else
              raise TypeError, "expected Numeric, Vector2 or Vector3"
            end
          end
          x, y, z, w = *params
        when 4
          x, y, z, w = *obj
        else
          raise ArgumentError, "expected Array of size 1, 2, 3, or 4"
        end
        return x, y, z, w
      when Hash
        return obj.fetch(:x), obj.fetch(:y), obj.fetch(:z)
      else
        raise TypeError, "wrong argument type (expected Array, Hash, Numeric or Vector3)"
      end
    end

    def self.[](*args)
      if args.size > 1
        new(*extract(args))
      else
        new(*extract(args.first))
      end
    end
  end
end
