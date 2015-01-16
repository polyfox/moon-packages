module Moon #:nodoc:
  class Scheduler #:nodoc:
    module Jobs #:nodoc:
      # Timeouts are one off tasks which will execute after their time has
      # expired.
      class Timeout < TimeBase
        # Has this timeout reached its end?
        #
        # @return [Boolean]
        def done?
          @time <= 0
        end

        # When time reaches 0 or less
        def on_timeout
          trigger
          deactivate
        end
      end
    end
  end
end
