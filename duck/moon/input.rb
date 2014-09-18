module Moon
  module Input
    module Mouse
      class << self
        attr_accessor :position
      end

      @position = Vector2.new(0, 0)
    end
  end
end
