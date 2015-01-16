module Moon #:nodoc:
  class Scheduler #:nodoc:
    module Jobs #:nodoc:
      # Processes are forever running jobs, unlike intervals which execute
      # after duration and simply restart, processes will call their
      # callback everytime they update.
      # To stop a process, simply #kill it.
      class Process < Base
        # @param [Float] delta
        def update_frame(delta)
          trigger(delta)
        end
      end
    end
  end
end
