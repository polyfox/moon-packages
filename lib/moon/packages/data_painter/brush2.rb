module Moon #:nodoc:
  module DataPainter #:nodoc:
    class Brush2
      # @return [Tabular::Cursor]
      attr_reader :dest

      def initialize(dest)
        @dest = dest
      end
    end
  end
end
