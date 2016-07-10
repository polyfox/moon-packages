module Moon
  class Vector1
    include Serializable::Properties
    include Serializable

    add_property :x
  end
end
