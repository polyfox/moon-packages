module TMX
  class Map < Moon::DataModel::Metal
    field :version,     type: Integer, default: 0
    field :width,       type: Integer, default: 0
    field :height,      type: Integer, default: 0
    field :tilewidth,   type: Integer, default: 0
    field :tileheight,  type: Integer, default: 0
    field :orientation, type: String,  default: "orthogonal"
    dict :properties,   key:  String,  value: String
    array :layers,      type: Layer
    array :tilesets,    type: Tileset
  end
end
