require 'scheduler/jobs/time_base'

module Moon
  class Scheduler
    module Jobs
      # Invertals are forever running jobs, they will execute their callback
      # after the duration has ended, and then restart, which is similar
      # behavior to a Timeout.
      class Interval < TimeBase
        # @return [Boolean]
        def done?
          killed?
        end

        # When time reaches 0 or less
        def on_timeout
          # since its possible that the timestep will be too large, it needs
          # to re-trigger the callback until the @time is greater than 0
          until @time > 0
            trigger_callback
            restart
          end
        end

        # Force end the interval, intervals can't "finish"
        def finish
          #
        end
      end
    end
  end
end
