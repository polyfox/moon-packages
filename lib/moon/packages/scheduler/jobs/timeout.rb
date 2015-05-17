require 'scheduler/jobs/time_base'

module Moon
  class Scheduler
    module Jobs
      # Timeouts are one off tasks which will execute after their time has
      # expired.
      class Timeout < TimeBase
        # Whether this timeout has already called its trigger method.
        # @return [Boolean]
        attr_reader :triggered

        # Has this timeout reached its end?
        #
        # @return [Boolean]
        def done?
          timeout? && @triggered
        end

        # When time reaches 0 or less
        def on_timeout
          trigger_callback
          @triggered = true
          deactivate
        end
      end
    end
  end
end
