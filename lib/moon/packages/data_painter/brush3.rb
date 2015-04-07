module Moon
  module DataPainter
    class Brush3
      # @return [MatrixLike::Cursor]
      attr_reader :dest

      def initialize(dest)
        @dest = dest
      end
    end
  end
end
