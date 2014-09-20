module TMX
  class Object < Moon::DataModel::Metal
    field :x,         type: Integer, default: 0
    field :y,         type: Integer, default: 0
    field :width,     type: Integer, default: 0
    field :height,    type: Integer, default: 0
    field :name,      type: String,  default: ""
    field :type,      type: String,  default: ""
    dict :properties, key:  String,  value: String
    field :visible,   type: Boolean, default: true
  end
end
