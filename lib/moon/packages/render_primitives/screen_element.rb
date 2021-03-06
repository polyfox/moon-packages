require 'render_primitives/rectangular'

module Moon
  module RenderPrimitive
    # I can be shot for this afterwards...
    module ScreenElement
      include Rectangular

      # Returns the expected screen position of the object
      #
      # @return [Vector2] position
      # @abstract Overwrite this in your class
      def screen_position
        position
      end

      # Convert a screen position to a relative position in the Container
      #
      # @overload screen_to_relative(x, y)
      #   @param [Integer] x
      #   @param [Integer] y
      # @overload screen_to_relative(vec2)
      #   @param [Moon::Vector2] vec2
      # @return [Moon::Vector2]
      def screen_to_relative(*args)
        s = screen_position
        vec2 = Vector2[*args]
        vec2.x -= s.x
        vec2.y -= s.y
        vec2
      end

      # Convert a relative position in the Container to a screen position
      #
      # @overload relative_to_screen(x, y)
      #   @param [Integer] x
      #   @param [Integer] y
      # @overload relative_to_screen(vec2)
      #   @param [Moon::Vector2] vec2
      # @return [Moon::Vector2]
      def relative_to_screen(*args)
        s = screen_position
        vec2 = Vector2[*args]
        vec2.x += s.x
        vec2.y += s.y
        vec2
      end

      # Determines if position is inside the Container
      #
      # @overload contains_pos?(x, y)
      #   @param [Integer] x
      #   @param [Integer] y
      # @overload contains_pos?(vec2)
      #   @param [Moon::Vector2] vec2
      # @return [Boolean]
      def contains_pos?(*args)
        s = screen_position
        px, py = *Vector2.extract(args.size > 1 ? args : args.first)
        px.between?(s.x, s.x + w) && py.between?(s.y, s.y + h)
      end

      # Determines if position is relatively inside the Container
      #
      # @overload contains_relative_pos?(x, y)
      #   @param [Integer] x
      #   @param [Integer] y
      # @overload contains_relative_pos?(vec2)
      #   @param [Moon::Vector2] vec2
      # @return [Boolean]
      def contains_relative_pos?(*args)
        px, py = *Vector2.extract(args.size > 1 ? args : args.first)
        px.between?(0, w) && py.between?(0, h)
      end
    end
  end
end
