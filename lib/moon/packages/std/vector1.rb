module Moon
  class Vector1
    # @return [Float]
    def sum
      x
    end

    # @return [Boolean]
    def zero?
      x == 0
    end

    # @return [Hash<Symbol, Float>]
    def to_h
      { x: x }
    end

    # @return [String]
    def to_s
      "#{x}"
    end

    # @param [Integer] index
    # @return [Float]
    def [](index)
      case index
      when :x, 'x', 0 then x
      end
    end

    # @param [Integer] index
    # @param [Float] value
    def []=(index, value)
      case index
      when :x, 'x', 0 then self.x = value
      end
    end

    def abs
      Moon::Vector1.new x.abs
    end
  end
end
