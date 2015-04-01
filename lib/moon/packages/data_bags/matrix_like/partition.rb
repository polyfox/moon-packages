module Moon
  module MatrixLike
    class Partition
      class Iterator < MatrixLike::IteratorBase
        #
      end

      include Tabular

      # @return [Moon::MatrixLike]
      attr_reader :src
      # @return [Integer]
      attr_reader :ox
      # @return [Integer]
      attr_reader :oy
      # @return [Integer]
      attr_reader :oz
      # @return [Integer]
      attr_reader :xsize
      # @return [Integer]
      attr_reader :ysize
      # @return [Integer]
      attr_reader :zsize
      # @return [Integer]
      attr_reader :size
    end
  end
end
