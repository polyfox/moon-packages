module Moon
  module Tabular
    # Partitions are used to mask a section of a Table for editing as if it
    # was a seperate Table, any changes done in the partition are done to the
    # underlaying +src+ Table, this is a nice way to trick other classes into
    # thinking its working with a Table
    class Partition
      class Iterator < Tabular::IteratorBase
        #
      end

      include Tabular

      # @return [Moon::Tabular]
      attr_reader :src
      # @return [Integer]
      attr_reader :ox
      # @return [Integer]
      attr_reader :oy
      # @return [Integer]
      attr_reader :xsize
      # @return [Integer]
      attr_reader :ysize
      # @return [Integer]
      attr_reader :size

      # @param [Moon::Table] src
      # @param [Moon::Rect] selection
      def initialize(src, selection)
        @src = src
        self.selection = selection
      end

      # @return [Integer]
      def default
        src.default
      end

      # @param [Integer] default
      def default=(default)
        src.default = default
      end

      # @return [Moon::Rect]
      def selection
        Rect.new(@ox, @oy, @xsize, @ysize)
      end

      # @param [Moon::Rect] selection
      def selection=(selection)
        @ox, @oy = selection.x.to_i, selection.y.to_i
        @xsize, @ysize = selection.w.to_i, selection.h.to_i
        @size = @xsize * @ysize
      end

      # @todo Validate that the new size is smaller than or equal to the src
      def resize(xsize, ysize)
        @xsize, @ysize = xsize, ysize
      end

      # @param [Integer] x
      # @param [Integer] y
      # @return [Integer]
      def [](x, y)
        return default unless contains?(x, y)
        src[x + ox, y + oy]
      end

      # @param [Integer] x
      # @param [Integer] y
      # @param [Integer] v
      def []=(x, y, v)
        return unless contains?(x, y)
        src[x + ox, y + oy] = v
      end

      # Initializes and returns an Iterator
      #
      # @return [Interator]
      def iter
        @iter ||= Iterator.new(self)
      end

      # @yieldparam [Integer] value  Value at the current position
      # @yieldparam [Integer] x  x-coord
      # @yieldparam [Integer] y  y-coord
      def map_with_xy
        iter.each_with_xy do |n, x, y|
          self[x, y] = yield self[x, y], x, y
        end
      end
    end
  end
end
