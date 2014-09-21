module Moon
  module RenderPrimitive
    module Containable
      attr_accessor :parent

      def containerize
        container = RenderContainer.new
        container.add(self)
        container
      end
    end
  end
end
