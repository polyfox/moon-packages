module Moon
  class Table
    # Initializes and returns a sampler
    #
    # @return [Sampler2]
    def sampler
      @sampler ||= Sampler2.new(self)
    end
  end
end
