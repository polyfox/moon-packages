##
# :nodoc:
module Moon
  ##
  #
  class Scheduler
    ##
    # @return [Array<Scheduler::Job::Base*>]
    attr_accessor :jobs
    ##
    # @return [Float] uptime  in seconds
    attr_reader :uptime
    ##
    # @return [Integer] ticks  in frames
    attr_reader :ticks

    ##
    # :nodoc:
    def initialize
      @jobs = []
      @paused = false
      @ticks = 0
      @uptime = 0.0
    end

    ##
    # Pauses the Scheduler
    def pause
      @paused = true
    end

    ##
    # Unpauses the Scheduler
    def resume
      @paused = false
    end

    ##
    # @param [Class<Scheduler::Job::Base>] klass
    # @param [Numeric, String] duration
    # @return [Scheduler::Job::Base<>] instance
    private def new_job(klass, duration, &block)
      duration = TimeUtil.parse_duration(duration) if duration.is_a?(String)
      job = klass.new(duration, &block)
      @jobs.push job
      job
    end

    ##
    # every(duration) { execute_every_duration }
    # @param [Integer] duration
    # @return [Interval]
    def every(duration, &block)
      new_job(Jobs::Interval, duration, &block)
    end

    ##
    # in(duration) { to_execute_on_timeout }
    # @param [Integer] duration
    # @return [Timeout]
    def in(duration, &block)
      new_job(Jobs::Timeout, duration, &block)
    end

    ##
    # Clears all jobs
    def clear
      @jobs.clear
      self
    end

    ##
    # Removes a job
    # @overload remove(obj)
    def remove(obj = nil)
      @jobs.delete(obj)
    end

    ##
    # Removes a job by id
    def remove_by_id(id)
      @jobs.delete { |job| job.id == id }
    end

    ##
    # Force all jobs to finish.
    # @return [Void]
    def finish
      return unless @jobs
      @jobs.each(&:finish)
    end

    ##
    # Frame update
    def update(delta)
      return if @paused
      dead = []
      @jobs.each do |task|
        task.update delta
        dead << task if task.done?
      end
      @jobs -= dead unless dead.empty?
      @uptime += delta
      @ticks += 1
    end
  end
end
