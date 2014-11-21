module Moon
  class Scheduler
    module Jobs
      class Base
        include Moon::Activatable

        attr_reader :id
        attr_reader :time
        attr_reader :duration

        def initialize(duration, &block)
          @id = Random.random.base64(16)
          @time = @duration = duration
          @callback = block
          @active = true
        end

        def rate
          @time / @duration
        end

        def done?
          false
        end

        def trigger
          @callback.try(:call)
        end

        ##
        # Called when a job's time has reached 0 or less
        # @abstract
        def on_timeout
          #
        end

        ##
        # @param [Float] delta
        # @abstract
        def update_frame(delta)
          #
        end

        ##
        # @param [Float] delta
        def update(delta)
          return unless active?
          update_frame(delta)
          @time -= delta
          on_timeout if @time <= 0
        end

        ###
        # Forces the Timeout to finish prematurely
        def finish
          @time = 0.0
          on_timeout
        end

        private :trigger
        private :on_timeout
      end
    end
  end
end
