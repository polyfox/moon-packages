##
# TMX loader module
module TMX
  ##
  # @param [Hash] data
  # @param [Integer] depth
  # @return [TMX::Map]
  def self.load(data, depth = 0)
    Map.load(data, depth + 1)
  end
end
