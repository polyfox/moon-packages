module Moon
  module RenderPrimitive
    module Visibility
      attr_accessor :visible

      def visible?
        !!@visible
      end

      def hide
        @visible = false
        self
      end

      def show
        @visible = true
        self
      end
    end
  end
end
