module Moon
  class DataMatrix
    # Initializes and returns a sampler
    #
    # @return [Sampler3]
    def sampler
      @sampler ||= Sampler3.new(self)
    end
  end
end
