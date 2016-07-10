module Moon
  class Vector4
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
    add_property :z
    add_property :w
  end
end
