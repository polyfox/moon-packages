module TMX #:nodoc:
  # TMX Map model
  class Map < Moon::DataModel::Metal
    # @!attribute version
    #   @return [Integer]
    field :version,     type: Integer, default: 0
    # @!attribute width
    #   @return [Integer]
    field :width,       type: Integer, default: 0
    # @!attribute height
    #   @return [Integer]
    field :height,      type: Integer, default: 0
    # @!attribute tilewidth
    #   @return [Integer]
    field :tilewidth,   type: Integer, default: 0
    # @!attribute tileheight
    #   @return [Integer]
    field :tileheight,  type: Integer, default: 0
    # @!attribute orientation
    #   @return [String]
    field :orientation, type: String,  default: 'orthogonal'
    # @!attribute properties
    #   @return [Hash<String, String>]
    dict :properties,   key:  String,  value: String
    # @!attribute layers
    #   @return [Array<TMX::Layer>]
    array :layers,      type: Layer
    # @!attribute tilesets
    #   @return [Array<TMX::Tileset>]
    array :tilesets,    type: Tileset
  end
end
