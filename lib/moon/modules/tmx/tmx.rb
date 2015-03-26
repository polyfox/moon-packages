##
# TMX loader module
module TMX
  # Loads a TMX map from the provided data
  #
  # @param [Hash] data
  # @param [Integer] depth  used for recursion checks.
  # @return [TMX::Map] the loaded map
  def self.load(data, depth = 0)
    Map.load(data, depth + 1)
  end
end
