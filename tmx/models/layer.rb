module TMX
  class Layer < Moon::DataModel::Metal
    field :x,       type: Integer, default: 0
    field :y,       type: Integer, default: 0
    field :height,  type: Integer, default: 0
    field :width,   type: Integer, default: 0
    field :name,    type: String,  default: ""
    field :type,    type: String,  default: ""
    array :data,    type: Integer, allow_nil: true
    array :objects, type: TMX::Object, allow_nil: true
    field :visible, type: Boolean, default: true
    field :opacity, type: Numeric, default: 1
  end
end
