require 'std/mixins/activatable'

module Moon
  # A Scheduler is used to manage Job objects, any object that implements
  # a #done? and #update can be used.
  # Adding a new job is done via #add, when a job is #done?, it will be removed
  # from the list of jobs, no further operations are done on the done job.
  class Scheduler
    include Moon::Activatable

    # @!attribute [rw] active
    # @return [Boolean] active  is the object active?
    attr_accessor :active

    # @!attribute [rw] jobs
    #   @return [Array<Moon::Scheduler::Job::Base*>]
    attr_accessor :jobs

    # @!attribute [r] uptime
    #   @return [Float] uptime  how long the scheduler has been running in seconds.
    attr_reader :uptime

    # @!attribute [r] ticks
    #   @return [Integer] ticks  how many times has the scheduler updated.
    attr_reader :ticks

    def initialize
      # temporary variable used for removing dead jobs
      @_dead = []
      @jobs = []
      @active = true
      @ticks = 0
      @uptime = 0.0
    end

    # Determines if the Scheduler is awake, if it has jobs and is active
    #
    # @return [Boolean]
    def awake?
      return false unless active?
      !@jobs.empty?
    end

    # Determins if the Scheduler is asleep, or idle
    #
    # @return [Boolean]
    def asleep?
      !awake?
    end

    # Add a job to the Scheduler
    #
    # @param [Moon::Scheduler::Jobs::Base] job
    # @return [self]
    def add(job)
      @jobs.push job
      job
    end

    # Clears all jobs, this will ignore the state of the job.
    #
    # @return [self]
    def clear
      @jobs.clear
      self
    end

    # Removes a job.
    #
    # @param [Moon::Scheduler::Job::Base*] job
    # @return [Object] the job removed
    def remove(job)
      @jobs.delete(job)
    end

    # Removes a job by id.
    #
    # @param [String] id
    # @return [Object] the job removed
    def remove_by_id(id)
      @jobs.reject! { |job| job.id == id }
    end

    # Removes jobs by tags
    #
    # @param [Array<String>] tags
    # @return [Array] the jobs removed
    def remove_by_tags(*tags)
      tags = tags.flatten
      @jobs.reject! { |job| job.tagged?(*tags) }
    end

    # Kill all active jobs.
    #
    # @return [Void]
    def kill
      return unless @jobs
      @jobs.each(&:kill)
    end

    # Creates a new Interval job
    #
    # @param [String, Integer] duration
    # @return [Moon::Scheduler::Jobs::Interval]
    def every(duration, &block)
      add Jobs::Interval.new(duration, &block)
    end

    # Creates a Timeout job
    #
    # @param [String, Integer] duration
    # @return [Moon::Scheduler::Jobs::Timeout]
    def in(duration, &block)
      add Jobs::Timeout.new(duration, &block)
    end

    # Creates a TimedProcess job
    #
    # @param [String, Integer] duration
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
    #
    # @param [Float] delta
    def update(delta)
      return unless awake?

      @jobs.each do |job|
        if job.done?
          @_dead << job
          next
        end
        job.update delta
      end
      unless @_dead.empty?
        @jobs -= @_dead
        @_dead.clear
      end
      @uptime += delta
      @ticks += 1
    end
  end
end
