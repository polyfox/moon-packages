require 'scheduler/jobs/time_base'

module Moon
  class Scheduler
    module Jobs
      # TimedProcess jobs are similar to Processes, they will run over their
      # provided duration.
      class TimedProcess < TimeBase
        class DoneEvent < Moon::Event
          def initialize
            super :done
          end
        end

        def on_timeout
          trigger DoneEvent.new
        end

        # @param [Float] delta
        def update_job_step(delta)
          trigger_callback delta, self
        end
      end
    end
  end
end
