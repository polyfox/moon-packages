module Moon
  class Clock
    attr_reader :start_time

    def initialize
      @start_time = current_time
    end

    def current_time
      Time.now.to_f
    end

    def elapsed
      current_time - @start_time
    end

    def restart
      now = current_time
      elasped = now - @start_time
      @start_time = now
      return elasped
    end
  end
end
