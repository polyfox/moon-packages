module Moon
  class Scheduler
    ### instance attribute
    attr_accessor :tasks
    attr_accessor :intervals

    ##
    # @type [Hash<String, Float>]
    DURATION_SUFFIX = {
      ""  => 0.001,
      "s" => 1.0,
      "m" => 60.0,
      "h" => 3600.0,
      "d" => 86400.0,
      "w" => 604800.0,
      "M" => 2592000.0,
      "y" => 31536000.0,
    }

    ###
    # @param [String] str
    # @return [Float] duration  in seconds
    def self.parse_duration(str)
      #   - milliseconds
      # s - seconds
      # m - minutes
      # h - hours
      # d - days
      # w - weeks
      # M - months
      # y - years
      # Now lets be honest here, who would be running this thing for more than
      # a few hours anyway...
      value = 0.0
      str.scan(/(\d+|\d+\.\d+)([smhdwMy])?/).each do |a|
        v = a[0].to_f
        suffix = a[1].to_s
        value = v * DURATION_SUFFIX[suffix]
      end
      value
    end

    def initialize
      @jobs = []
      @paused = false
      @tick = 0.0
    end

    ###
    # @return [Float] uptime  in seconds
    ###
    def uptime
      @tick
    end

    ###
    # Pauses the Scheduler
    ###
    def pause
      @paused = true
    end

    ###
    # Unpauses the Scheduler
    ###
    def resume
      @paused = false
    end

    ###
    # every(duration) { execute_every_duration }
    ###
    def every(duration, &block)
      duration = self.class.parse_duration(duration) if duration.is_a?(String)
      interval = Interval.new(duration, &block)
      @jobs.push interval
      interval
    end

    ###
    # in(duration) { to_execute_on_timeout }
    # @param [Integer] duration
    # @return [Timeout]
    ###
    def in(duration, &block)
      duration = self.class.parse_duration(duration) if duration.is_a?(String)
      timeout = Timeout.new(duration, &block)
      @jobs.push timeout
      timeout
    end

    ###
    # Clears all jobs
    ###
    def clear
      @jobs.clear
    end

    ###
    # Removes a job
    # @overload remove(obj)
    ###
    def remove(obj=nil)
      @jobs.delete(obj)
    end

    ###
    # Removes a job by id
    ###
    def remove_by_id(id)
      @jobs.delete { |job| job.id == id }
    end

    ###
    # Force all jobs to finish.
    # @return [Void]
    ###
    def finish
      return unless @jobs
      @jobs.each(&:finish)
    end

    ###
    # Frame update
    ###
    def update(delta)
      return if @paused
      dead = []
      @jobs.each do |task|
        task.update delta
        dead << task if task.done?
      end
      @jobs -= dead unless dead.empty?
      @tick += delta
    end
  end
end
