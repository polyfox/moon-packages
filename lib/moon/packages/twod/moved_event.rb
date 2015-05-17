module Moon
  class MovedEvent < Event
    attr_accessor :parent
    attr_accessor :old_position
    attr_accessor :position

    def initialize(parent, old_position, position)
      @parent = parent
      @old_position = old_position
      @position = position
      super :moved
    end
  end
end
