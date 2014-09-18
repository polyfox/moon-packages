module Moon
  class Option
    attr_accessor :value
    def initialize(value)
      @value = value
    end

    def map(symbol, *args, &block)
      @value = @value.send(symbol, *args, &block)
    end

    def exist?
      @value != nil
    end
  end
end
