##
# Based loosely off the RPG Maker RPG::BaseItem class
module Moon
  module DataModel
    class Base < Metal
      # ID of the model
      # @!attribute id
      #   @return [String]
      field :id,   type: String,           default: proc { Random.random.base64(16) }
      # Name of this model
      # @!attribute name
      #   @return [String]
      field :name, type: String,           default: proc { '' }
      # A string for describing this DataModel
      # @!attribute note
      #   @return [String]
      field :note, type: String,           default: proc { '' }
      # Used for lookups
      # @!attribute tags
      #   @return [Array<String>]
      array :tags, type: String
      # Meta Data, String Values and String Keys
      # @!attribute meta
      #   @return [Hash<String, String>]
      dict :meta,  key: String, value: String default: proc { {} }
    end
  end
end
