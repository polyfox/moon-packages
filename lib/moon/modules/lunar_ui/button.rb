module Lunar #:nodoc:
  class Button < Widget
    class ButtonEvent < Moon::Event
      attr_reader :button

      def initialize(button, key)
        @button = button
        super key
      end
    end

    class PressEvent < ButtonEvent
      def initialize(button)
        super button, :button_press
      end
    end

    class DepressEvent < ButtonEvent
      def initialize(button)
        super button, :button_depress
      end
    end

    # @return [Moon::Text]
    attr_reader :text

    ##
    #
    def init_elements
      super
      @text = Text.new
      add(@text)
    end

    def init_widget_events
      super
      init_button_events
    end

    def init_button_events
      on :press, :mouse_left do |e|
        trigger PressEvent.new(self) if screen_bounds.contains?(e.position)
      end

      on :release, :mouse_left do |e|
        trigger DepressEvent.new(self) if screen_bounds.contains?(e.position)
      end
    end
  end
end
