module Moon
  class Scheduler
    module Jobs
      # Base class for all Scheduler jobs, this is completely optional
      # for custom user jobs, as long as they implement the basic methods
      # for the job API, (#update, #done?).
      class Base
        include Moon::Activatable

        # @return [String]
        attr_reader :id
        # How long has this job been running?
        # @return [Float]
        attr_reader :uptime
        # @return [Boolean]
        attr_reader :killed

        def initialize(&block)
          @id = Random.random.base64(16)
          @active = true
          @callback = block
          @killed = false
          @uptime = 0.0
        end

        # Is this job done?
        #
        # @return [Boolean]
        def done?
          killed?
        end

        # Calls the callback
        def trigger(*args)
          @callback.call(*args) if @callback
        end

        # Called everytime the Job updates, use this method to continous
        # updating jobs.
        #
        # @param [Float] delta
        # @abstract
        def update_frame(delta)
          #
        end

        # @param [Float] delta
        def update(delta)
          return unless active?
          update_frame(delta)
        end

        # Sets the killed flag
        def kill
          @killed = true
        end

        # @return [Boolean]
        def killed?
          @killed
        end

        private :trigger
      end
    end
  end
end
