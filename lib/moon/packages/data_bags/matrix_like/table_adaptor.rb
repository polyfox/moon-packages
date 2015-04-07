module Moon
  module MatrixLike
    # A wrapper class around a DataMatrix instance to allow Table like behaviour
    class TableAdaptor
      include Tabular

      # @return [Moon::MatrixLike]
      attr_reader :src
      # @return [Integer]
      attr_accessor :z

      # @param [MatrixLike] src
      def initialize(src)
        @src = src
        @z = 0
      end

      # @return [Integer]
      def xsize
        src.xsize
      end

      # @return [Integer]
      def ysize
        src.ysize
      end

      # @param [Integer] x
      # @param [Integer] y
      # @return [Integer]
      def [](x, y)
        src[x, y, z]
      end

      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] value
      def []=(x, y, value)
        src[x, y, z] = value
      end
    end
  end
end
