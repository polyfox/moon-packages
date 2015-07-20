module Moon
  class Input
    class Observer
      attr_accessor :on_exception

      include Eventable

      def initialize
        initialize_eventable
      end

      def clear
        clear_events
      end

      private def handle_exception(exc, backtrace)
        if @on_exception
          @on_exception.call(exc, backtrace)
        else
          puts 'Input Error occured: ' << exc.inspect
          backtrace.each do |line|
            puts "\t#{line}"
          end
          raise exc
        end
      end

      def trigger(event)
        super
      # Input events may be triggered, outside of a State#step, since
      # input events are not polled, this can sometimes bypass State
      # breakpads and end up bubbling back to the engine level.
      # Use an on_exception callback to hook the error and handle
      # it elsewhere instead of bubbling back up.
      rescue => exc
        handle_exception(exc, exc.backtrace.dup)
      end
    end
  end
end
