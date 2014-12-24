module Moon
  module Input
    class Observer
      include Eventable

      def initialize
        init_eventable
      end

      def clear
        clear_events
      end

      # Debugging
      #def trigger(event)
      #  p event
      #  super
      #end
    end
  end
end
