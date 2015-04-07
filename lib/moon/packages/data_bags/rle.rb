module Moon
  # RunLengthEncoded Program
  class RleProgram
    attr_reader :instructions

    def initialize
      @instructions = []
      @poll = nil
      if block_given?
        yield self
        flush
      end
    end

    # Clear all existing instructions and reset the poll
    def clear
      @instructions = []
      @poll = nil
    end

    #
    def put(d)
      flush
      @instructions << [:put, d]
    end

    def skip
      @poll ||= [:skip, 0]
      @poll[1] += 1
    end

    def flush
      if @poll
        @instructions << @poll
        @poll = nil
      end
    end

    def encode(data)
      clear
      data.each do |d|
        yield d ? put(d) : skip
      end
      flush
    end

    def run
      i = 0
      @instructions.each do |inst|
        op, value = *inst
        case op
        when :skip
          i += value
        when :put
          yield value, i
          i += 1
        end
      end
    end
  end
end
