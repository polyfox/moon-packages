module Moon
  module RenderPrimitive
    # Interface for making objects #render-able, overwrite the #render_abs,
    # in your object
    module Renderable
      # @return [Boolean] should this render?
      def render?
        true
      end

      # Overwrite this method in your object to do actual rendering.
      # Note this method is only called if #render? is true.
      #
      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] z
      # @param [Hash<Symbol, Object>] options
      # @abstract
      protected def render_abs(x, y, z, options)
        #
      end

      # Outward facing render method, DO NOT OVERWRITE THIS
      #
      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] z
      # @param [Hash<Symbol, Object>] options
      # @api public
      def render(x = 0, y = 0, z = 0, options = {})
        render_abs(x, y, z, options) if render?
      end
    end
  end
end
