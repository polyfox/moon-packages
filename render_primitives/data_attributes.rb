module Moon #:nodoc:
  module RenderPrimitive #:nodoc:
    module DataAttributes
      attr_accessor :data_attrs

      def init_data_attrs
        @data_attrs = {}
      end
    end
  end
end
