module Moon #:nodoc:
  module RenderPrimitive #:nodoc:
    ##
    # Mixin for containerizing RenderContext objects in a RenderContainer
    module Containable
      # @return [Moon::RenderPrimitive::Containable]
      attr_accessor :parent

      ##
      # Parent containers call this method to invalidate their children
      # @return [Void]
      def disown
        self.parent = nil
      end

      ##
      # Wrap this into a RenderContainer
      # @return [Moon::RenderContainer]
      def containerize
        container = RenderContainer.new
        container.add(self)
        container
      end
    end
  end
end
