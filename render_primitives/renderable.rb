module Moon
  module RenderPrimitive
    module Renderable
      ##
      # @return [Boolean] should this render?
      def render?
        true
      end

      ##
      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] z
      # @param [Hash<Symbol, Object>] options
      # @abstract
      private def render_abs(x, y, z, options)
        #
      end

      ##
      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] z
      # @param [Hash<Symbol, Object>] options
      def render(x = 0, y = 0, z = 0, options = {})
        render_abs(x, y, z, options) if render?
      end
    end
  end
end
