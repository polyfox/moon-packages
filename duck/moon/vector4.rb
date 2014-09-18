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
  end
end
