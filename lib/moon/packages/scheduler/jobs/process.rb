require 'scheduler/jobs/base'

module Moon
  class Scheduler
    module Jobs
      # Processes are forever running jobs, unlike intervals which execute
      # after duration and simply restart, processes will call their
      # callback everytime they update.
      # To stop a process, simply #kill it.
      class Process < Base
        # @param [Float] delta
        def update_job(delta)
          trigger_callback(delta, self)
        end
      end
    end
  end
end
