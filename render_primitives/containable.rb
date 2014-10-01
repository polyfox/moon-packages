module Moon
  module RenderPrimitive
    module Containable
      attr_accessor :parent

      def disown
        self.parent = nil
      end

      def containerize
        container = RenderContainer.new
        container.add(self)
        container
      end
    end
  end
end
