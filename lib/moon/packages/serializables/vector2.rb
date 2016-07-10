require 'std/vector2'

module Moon
  class Vector2
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
  end
end
