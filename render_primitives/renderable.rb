module Moon
  module RenderPrimitive
    module Renderable
      def render?
        true
      end

      private def render_abs(x, y, z, options={})
        #
      end

      def render(x=0, y=0, z=0, options={})
        render_abs(x, y, z, options) if render?
      end
    end
  end
end
