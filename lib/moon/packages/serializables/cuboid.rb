require 'std/cuboid'

module Moon
  class Cuboid
    include Serializable::Properties
    include Serializable

    # @return [Integer]
    add_property :x
    # @return [Integer]
    add_property :y
    # @return [Integer]
    add_property :z
    # @return [Integer]
    add_property :w
    # @return [Integer]
    add_property :h
    # @return [Integer]
    add_property :d
  end
end
