require 'scheduler/jobs/base'

module Moon
  class Scheduler
    module Jobs
      # TimeBase is the base class for all timebound events.
      class TimeBase < Base
        # @return [Float]
        attr_reader :time

        # @return [Float]
        attr_reader :duration

        # @param [Float, String] duration
        def initialize(duration, &block)
          @time = self.duration = TimeUtil.to_duration(duration)
          super(&block)
        end

        # @param [String, Numeric] dur  duration
        def duration=(dur)
          @duration = TimeUtil.to_duration(dur)
        end

        # @return [Boolean]
        def timeout?
          @time <= 0
        end

        # @return [Boolean]
        def done?
          killed? || timeout?
        end

        # @return [Float]
        def rate
          @time / @duration
        end

        # Called when a job's time has reached 0 or less
        #
        # @abstract
        def on_timeout
          #
        end
        private :on_timeout

        # @param [Float] delta
        def update_job_step(delta)
        end

        # @param [Float] delta
        def update_job(delta)
          @time -= delta
          update_job_step(delta)
          on_timeout if @time <= 0
        end

        # Sets the time to 0.0, which is the end.
        def stop
          @time = 0.0
        end

        # Sets the time to the duration, ultimately restarting the job's
        # internal timer.
        def restart
          @time += @duration
        end

        # Finish will force the job to stop, and call {#on_timeout},
        # use {#stop} instead if you only wish to end the job only, without
        # calling {#on_timeout}
        def finish
          stop
          on_timeout
        end
      end
    end
  end
end
