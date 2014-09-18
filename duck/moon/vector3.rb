module Moon
  class Vector3 < Moon::DataModel::Metal
    field :x,      type: Numeric, default: 0.0
    field :y,      type: Numeric, default: 0.0
    field :z,      type: Numeric, default: 0.0

    alias :r :x
    alias :r= :x=
    alias :g :y
    alias :g= :y=
    alias :b :z
    alias :b= :z=

    def initialize(*args, &block)
      set(*args, &block)
    end

    def to_a
      return x, y, z
    end

    alias :dm_set :set
    def set(*args, &block)
      case args.size
      when 1
        dm_set args.first, &block
      when 3
        x, y, z = *args
        dm_set x: x, y: y, z: z, &block
      else
        dm_set x: 0.0, y: 0.0, z: 0.0, &block
      end
    end
  end
end
