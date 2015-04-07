module Moon
  # Tabular objects are expected to respond to:
  #   xsize -> Integer
  #   ysize -> Integer
  #   [](x, y) -> Integer
  #   []=(x, y, value)
  # As well as implementing the methods required by IteratorBase
  module Tabular
    # Iteratable Tabular objects are expected to respond to:
    #   xsize -> Integer
    #   ysize -> Integer
    #   [](x, y) -> Integer
    class IteratorBase
      # @return [Moon::Tabular]
      attr_reader :src

      # @param [Moon::Tabular] src
      def initialize(src)
        @src = src
      end

      # @yieldparam [Integer] value  Value
      # @yieldparam [Integer] x  x-Coord
      # @yieldparam [Integer] y  y-Coord
      def each_with_xy
        xs, ys = src.xsize, src.ysize
        ys.times do |y|
          xs.times do |x|
            yield src[x, y], x, y
          end
        end
      end

      # @yieldparam [Integer] value  Value
      def each
        each_with_xy { |n, _, _| yield n }
      end

      # Iterates and yields each rows data
      #
      # @yieldparam [Integer] value  Value
      # @yieldparam [Integer] y  Row
      def each_row
        xs = src.xsize
        src.ysize.times do |y|
          yield xs.times.map { |x| src[x, y] }
        end
      end

      # Iterates and yields each columns data
      #
      # @yieldparam [Integer] value  Value
      # @yieldparam [Integer] x  Column
      def each_column
        ys = src.ysize
        src.xsize.times do |x|
          yield ys.times.map { |y| src[x, y] }
        end
      end
    end

    # Determines if given position is within the table bounds.
    #
    # @param [Integer] x
    # @param [Integer] y
    # @return [Boolean] contains  Whether or not the position is contained
    def contains?(x, y)
      x, y = x.to_i, y.to_i
      return ((x >= 0) && (x < xsize)) &&
             ((y >= 0) && (y < ysize))
    end

    # @return [Moon::Vector2]
    def sizes
      Moon::Vector2.new xsize, ysize
    end

    # @return [Moon::Rect]
    def rect
      Moon::Rect.new 0, 0, xsize, ysize
    end

    # Initializes and returns an Iterator
    #
    # @return [Interator]
    def iter
      @iter ||= IteratorBase.new(self)
    end

    # @yieldparam [Integer] value  Value at the current position
    # @yieldparam [Integer] x  x-Coord
    # @yieldparam [Integer] y  y-Coord
    def map_with_xy
      iter.each_with_xy do |n, x, y|
        self[x, y] = yield self[x, y], x, y
      end
    end

    # Set a Table's data from a String and a Dictionary
    #
    # @param [String] str  String to transcode
    # @param [Hash<String, Integer>] dict  Lookup table to transcoding characters
    # @return [self]
    def set_by_dict(str, dict)
      str.split("\n").each do |row|
        row.size.times do |i|
          self[i % xsize, i / xsize] = dict.fetch(row[i])
        end
      end
      self
    end
  end
end
