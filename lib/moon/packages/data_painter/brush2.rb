module Moon
  module DataPainter
    class Brush2
      # @return [Tabular::Cursor]
      attr_reader :dest

      def initialize(dest)
        @dest = dest
      end
    end
  end
end
