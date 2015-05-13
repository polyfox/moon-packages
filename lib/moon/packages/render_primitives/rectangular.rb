module Moon
  module RenderPrimitive
    module Rectangular
      # @return [Moon::Vector3]
      attr_accessor :position
      # @return [Integer]
      attr_accessor :w
      # @return [Integer]
      attr_accessor :h

      ##
      # @return [Integer]
      def x
        @position.x
      end

      ##
      # @param [Integer] x
      def x=(x)
        @position.x = x
      end

      ##
      # @return [Integer]
      def y
        @position.y
      end

      ##
      # @param [Integer] y
      def y=(y)
        @position.y = y
      end

      ##
      # @return [Integer]
      def z
        @position.z
      end

      ##
      # @param [Integer] z
      def z=(z)
        @position.z = z
      end

      ##
      # @return [Integer]
      def x2
        x + w
      end

      ##
      # @param [Integer] x2
      def x2=(x2)
        @position.x = x2 - w
      end

      ##
      # @return [Integer]
      def y2
        y + h
      end

      ##
      # @param [Integer] y2
      def y2=(y2)
        @position.y = y2 - h
      end

      ##
      # @return [Integer]
      def cx
        x + w / 2
      end

      ##
      # @return [Integer]
      def cy
        y + h / 2
      end

      ##
      # @param [Integer] cx
      def cx=(cx)
        self.x = cx - w / 2
      end

      ##
      # @param [Integer] cy
      def cy=(cy)
        self.y = cy - h / 2
      end

      ##
      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] z
      #   @optional
      # @return [self]
      def move(x, y, z = self.z)
        @position.set(x, y, z)
        self
      end

      # @param [Symbol] attrs  attributes modified
      # @return [void]
      def on_resize(*attrs)
        #
      end

      # Resize the object
      # @param [Integer] w  width
      # @param [Integer] h  height
      # @return [self]
      def resize(w, h)
        @w, @h = w, h
        on_resize :w, :h
        self
      end

      ##
      # @param [String] command
      # @param [Moon::RenderPrimitive::Rectangular] rect
      private def align_command!(command, rect)
        case command
        when 'center'
          self.cx = rect.cx
          self.cy = rect.cy
        when 'middle-horz'
          self.cx = rect.cx
        when 'middle-vert'
          self.cy = rect.cy
        when 'left'
          self.x  = rect.x
        when 'right'
          self.x2 = rect.x2
        when 'top'
          self.y  = rect.y
        when 'bottom'
          self.y2 = rect.y2
        end
      end

      ##
      # @param [String] str  alignment commands, space seperated words
      # @param [Moon::RenderPrimitive::Rectangular] rect  Object to align against
      # @return [self]
      def align!(str, rect)
        str.split(' ').each do |command|
          align_command!(command, rect)
        end
        self
      end

      ##
      # @return [Moon::Rect] bounds
      def bounds
        Moon::Rect.new(x, y, w, h)
      end

      ##
      # @return [Moon::Rect] rect
      def to_rect
        Moon::Rect.new(x, y, w, h)
      end

      ##
      # @return [Boolean] is the position inside the rectanagle?
      def contains?(cx, cy)
        cx.between?(x, x2 - 1) && cy.between?(y, y2 - 1)
      end
    end
  end
end
