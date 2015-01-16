module Moon #:nodoc:
  ##
  # A Scheduler is used to manage Job objects, any object that implements
  # a #done? and #update can be used.
  # Adding a new job is done via #add, when a job is #done?, it will be removed
  # from the list of jobs, no further operations are done on the done job.
  # If you wish to have something like a on_done callback, implement it in
  # the job.
  class Scheduler
    include Moon::Activatable

    ##
    # @return [Array<Moon::Scheduler::Job::Base*>]
    attr_accessor :jobs
    ##
    # @return [Float] uptime  in seconds
    attr_reader :uptime
    # Keeps count of how many times the Scheduler has been updated.
    # @return [Integer] ticks  in frames
    attr_reader :ticks

    # :nodoc:
    def initialize
      @jobs = []
      @active = true
      @ticks = 0
      @uptime = 0.0
    end

    # @param [Moon::Scheduler::Jobs::Base]
    def add(job)
      @jobs.push job
      job
    end

    # Clears all jobs, this will ignore the state of the job.
    def clear
      @jobs.clear
      self
    end

    # Removes a job.
    #
    # @param [Moon::Scheduler::Job::Base*] job
    def remove(job)
      @jobs.delete(job)
    end

    # Removes a job by id.
    #
    # @param [String] id
    def remove_by_id(id)
      @jobs.delete { |job| job.id == id }
    end

    ##
    # Kill all active jobs.
    #
    # @return [Void]
    def kill
      return unless @jobs
      @jobs.each(&:kill)
    end

    # Creates a new Interval job
    #
    # @param [Integer] duration
    # @return [Moon::Scheduler::Jobs::Interval]
    def every(duration, &block)
      add Jobs::Interval.new(duration, &block)
    end

    # Creates a Timeout job
    #
    # @param [Integer] duration
    # @return [Moon::Scheduler::Jobs::Timeout]
    def in(duration, &block)
      add Jobs::Timeout.new(duration, &block)
    end

    # Creates a TimedProcess job
    #
    # @return [Moon::Scheduler::Jobs::TimedProcess]
    def run_for(duration, &block)
      add Jobs::TimedProcess.new(duration, &block)
    end

    # Creates a Process job
    #
    # @return [Moon::Scheduler::Jobs::Process]
    def run(&block)
      add Jobs::Process.new(&block)
    end

    # Frame update
    # @param [Float] delta
    def update(delta)
      return unless active?
      dead = []
      @jobs.each do |job|
        if job.done?
          dead << job
          next
        end
        job.update delta
      end
      @jobs -= dead unless dead.empty?
      @uptime += delta
      @ticks += 1
    end
  end
end
