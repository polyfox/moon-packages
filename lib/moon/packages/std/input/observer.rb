module Moon
  class Input
    class Observer
      include Eventable

      def initialize
        init_eventable
      end

      def clear
        clear_events
      end
    end
  end
end
