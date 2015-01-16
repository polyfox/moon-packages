module Moon #:nodoc:
  class Scheduler #:nodoc:
    module Jobs #:nodoc:
      # Invertals are forever running jobs, they will execute their callback
      # after the duration has ended, and then restart, which is similar
      # behavior to a Timeout.
      class Interval < TimeBase
        # When time reaches 0 or less
        def on_timeout
          trigger
          restart
        end

        # Force end the interval
        # Intervals do nothing on #finish
        def finish
          #
        end
      end
    end
  end
end
