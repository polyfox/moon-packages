module TMX #:nodoc:
  # TMX Tileset model
  class Tileset < Moon::DataModel::Metal
    # @!attribute firstgid
    #   @return [Integer]
    field :firstgid,    type: Integer, default: 1
    # @!attribute name
    #   @return [String]
    field :name,        type: String,  default: ''
    # @!attribute image
    #   @return [String]
    field :image,       type: String,  default: ''
    # @!attribute imagewidth
    #   @return [Integer]
    field :imagewidth,  type: Integer, default: 0
    # @!attribute imageheight
    #   @return [Integer]
    field :imageheight, type: Integer, default: 0
    # @!attribute tilewidth
    #   @return [Integer]
    field :tilewidth,   type: Integer, default: 0
    # @!attribute tileheight
    #   @return [Integer]
    field :tileheight,  type: Integer, default: 0
    # @!attribute margin
    #   @return [Integer]
    field :margin,      type: Integer, default: 0
    # @!attribute spacing
    #   @return [Integer]
    field :spacing,     type: Integer, default: 0
    # @!attribute properties
    #   @return [Hash<String, String>]
    dict :properties,   key:  String,  value: String
  end
end
