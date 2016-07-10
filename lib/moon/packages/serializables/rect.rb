require 'std/rect'

module Moon
  class Rect
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
    add_property :w
    add_property :h
  end
end
