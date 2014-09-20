module TMX
  class Tileset < Moon::DataModel::Metal
    field :firstgid,    type: Integer, default: 1
    field :name,        type: String,  default: ""
    field :image,       type: String,  default: ""
    field :imagewidth,  type: Integer, default: 0
    field :imageheight, type: Integer, default: 0
    field :tilewidth,   type: Integer, default: 0
    field :tileheight,  type: Integer, default: 0
    field :margin,      type: Integer, default: 0
    field :spacing,     type: Integer, default: 0
    dict :properties,   key:  String,  value: String
  end
end
