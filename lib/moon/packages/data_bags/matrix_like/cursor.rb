module Moon
  module MatrixLike
    class Cursor
      # @return [Moon::DataMatrix]
      attr_reader :src
      # @return [Moon::Vector3]
      attr_accessor :position

      # @param [Moon::Table] src
      def initialize(src)
        @position = Vector3.zero
        @src = src
      end
    end
  end
end
