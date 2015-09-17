require 'std/mixins/activatable'
require 'std/mixins/eventable'
require 'std/mixins/taggable'

module Moon
  class Scheduler
    module Jobs
      # Base class for all Scheduler jobs, this is completely optional
      # for custom user jobs, as long as they implement the basic methods
      # for the job API, (#update, #done?).
      class Base
        include Moon::Eventable
        include Moon::Activatable
        include Moon::Taggable

        # @!attribute [rw] active
        # @return [Boolean] active  is the object active?
        attr_accessor :active

        # @return [String]
        attr_reader :id

        # How long has this job been running?
        # @return [Float]
        attr_reader :uptime

        # @!attribute [r] killed
        #   @return [Boolean] Was the job killed?
        attr_reader :killed

        # @!attribute tags
        #   @return [Array<String>] tags
        attr_accessor :tags

        def initialize(&block)
          @id = Random.random.base64(16)
          @callback = block
          @active = true
          @killed = false
          @uptime = 0.0
          @tags   = []
          initialize_eventable
        end

        # Is this job done?
        #
        # @return [Boolean]
        def done?
          killed?
        end

        # Calls the callback
        def trigger_callback(*args)
          @callback.call(*args) if @callback
        end

        # Called everytime the Job updates, use this method to continous
        # updating jobs.
        #
        # @param [Float] delta
        # @abstract
        def update_job(delta)
          #
        end

        # @param [Float] delta
        def update(delta)
          return unless active?
          update_job(delta)
          @uptime += delta
        end

        # Sets the killed flag
        #
        # @return [self]
        def kill
          @killed = true
          self
        end

        # Was the job killed?
        #
        # @return [Boolean]
        def killed?
          @killed
        end

        private :trigger
      end
    end
  end
end
