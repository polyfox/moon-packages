module Moon
  class Rect < Moon::DataModel::Metal
    field :x,      type: Numeric, default: 0
    field :y,      type: Numeric, default: 0
    field :width,  type: Numeric, default: 0
    field :height, type: Numeric, default: 0

    def initialize(x, y, width, height, &block)
      super x: x, y: y, width: width, height: height, &block
    end
  end
end
