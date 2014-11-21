module Moon
  module RenderPrimitive
    module Rectangular
      attr_accessor :position
      attr_accessor :width
      attr_accessor :height

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
        x + width
      end

      ##
      # @param [Integer] x2
      def x2=(x2)
        @position.x = x2 - width
      end

      ##
      # @return [Integer]
      def y2
        y + height
      end

      ##
      # @param [Integer] y2
      def y2=(y2)
        @position.y = y2 - height
      end

      ##
      # @return [Integer]
      def cx
        x + width / 2
      end

      ##
      # @return [Integer]
      def cy
        y + height / 2
      end

      ##
      # @param [Integer] cx
      def cx=(cx)
        self.x = cx - width / 2
      end

      ##
      # @param [Integer] cy
      def cy=(cy)
        self.y = cy - height / 2
      end

      ##
      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] z
      #   @optional
      # @return [self]
      def move(x, y, z=self.z)
        @position.set(x, y, z)
        self
      end

      ##
      # Resize the object
      # @param [Integer] w  width
      # @param [Integer] h  height
      # @return [self]
      def resize(w, h)
        @width, @height = w, h
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
      # @return [Rect] bounds
      def bounds
        Moon::Rect.new(x, y, width, height)
      end

      ##
      # @return [Rect] rect
      def to_rect
        Moon::Rect.new(x, y, width, height)
      end
    end
  end
end
