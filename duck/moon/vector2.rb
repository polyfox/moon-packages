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
  end
end
