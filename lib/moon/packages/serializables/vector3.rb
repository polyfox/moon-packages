module Moon
  class Vector3
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
    add_property :z
  end
end
