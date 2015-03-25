module Moon #:nodoc:
  class Scheduler #:nodoc:
    module Jobs #:nodoc:
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
          @time <= 0 && @triggered
        end

        # When time reaches 0 or less
        def on_timeout
          trigger
          @triggered = true
          deactivate
        end
      end
    end
  end
end
