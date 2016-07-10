module Moon
  class Cuboid
    include Serializable::Properties
    include Serializable

    # @return [Integer]
    property_accessor :x
    # @return [Integer]
    property_accessor :y
    # @return [Integer]
    property_accessor :z
    # @return [Integer]
    property_accessor :w
    # @return [Integer]
    property_accessor :h
    # @return [Integer]
    property_accessor :d
  end
end
