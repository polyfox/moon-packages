# Duck typing
module Moon
  class Vector2 < Moon::DataModel::Metal
    field :x,      type: Numeric, default: 0.0
    field :y,      type: Numeric, default: 0.0

    def initialize(*args, &block)
      set(*args, &block)
    end

    def to_a
      return x, y
    end

    alias :dm_set :set
    def set(*args, &block)
      case args.size
      when 1
        dm_set args.first, &block
      when 2
        x, y = *args
        dm_set x: x, y: y, &block
      else
        dm_set x: 0.0, y: 0.0, &block
      end
    end

    def +(other)
      ox, oy = *self.class.extract(other)
      self.class.new(x + ox, y + oy)
    end

    def -(other)
      ox, oy = *self.class.extract(other)
      self.class.new(x - ox, y - oy)
    end

    def *(other)
      ox, oy = *self.class.extract(other)
      self.class.new(x * ox, y * oy)
    end

    def /(other)
      ox, oy = *self.class.extract(other)
      self.class.new(x / ox, y / oy)
    end

    def -@
      self.class.new(-x, -y)
    end

    def self.extract(obj)
      case obj
      when Numeric
        return obj, obj, obj
      when Vector2
        return *obj
      when Array
        case obj.size
        when 1
          x, y = *obj.first
        when 2
          x, y = *obj
        else
          raise ArgumentError, "expected Array of size 1 or 2"
        end
        return x, y
      when Hash
        return obj.fetch(:x), obj.fetch(:y)
      else
        raise TypeError, "wrong argument type (expected Array, Hash, Numeric or Vector2)"
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
