require 'scheduler/jobs/timed_process'
require 'animation/easing'

module Moon
  class Transition < Scheduler::Jobs::TimedProcess
    ### instance attributes
    attr_accessor :easer

    # @param [Object] src
    # @param [Object] dest
    # @param [String, Numeric] duration
    # @param [#call] easer
    def initialize(src, dest, duration, easer = Easing::Linear, &block)
      super(duration, &block)
      setup(src, dest, easer)
    end

    # @param [Object] src
    # @param [Object] dest
    # @param [#call] easer
    # @return [self]
    def setup(src, dest, easer = Easing::Linear)
      @src = src
      @dest = dest
      @easer = easer
      self
    end

    # @param [Float] delta
    # @return [void]
    def update_ease(delta)
      time_inv = (@duration - @time).clamp(0, @duration)
      @callback.call(@src + (@dest - @src) * @easer.call(time_inv / @duration))
    end

    # @param [Float] delta
    # @return [void]
    def update_job_step(delta)
      update_ease delta
    end
  end
end
