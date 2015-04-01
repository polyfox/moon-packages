module Moon #:nodoc:
  # Sampler2 is a class used for sampling data from a Tabular object.
  # Samplers do not modify the underlying data.
  class Sampler2
    # @!attribute [r] src
    #   @return [Tabular]
    attr_reader   :src
    # @!attribute [rw] factory2
    #   @return [Object] object used for creating new Table objects.
    attr_accessor :factory2

    # @param [Object] src
    # @param [Hash<Symbol, Object>] options
    #   @option options [#new] factory2
    def initialize(src, options = {})
      @src = src
      @factory2 = options.fetch(:factory2) { Table }
    end

    # Gets data at the given position.
    #
    # @param [Integer] x
    # @param [Integer] y
    # @return [Integer]
    def [](x, y)
      src[x, y]
    end

    # Takes a section of the +src+ and creates a new object from it.
    #
    # @overload subsample(rect)
    #   @param [Moon::Rect, Array<Integer>] rect
    # @overload subsample(x, y, w, h)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] w
    #   @param [Integer] h
    # @return [Tabular]
    def subsample(*args)
      rx, ry, rw, rh = *Rect.extract(args.singularize)
      result = factory2.new(rw, rh, default: src.default)
      result.ysize.times do |y|
        dy = y + ry
        result.xsize.times do |x|
          result[x, y] = src[x + rx, dy]
        end
      end
      result
    end

    # Samples all the data in column +x+
    #
    # @param [Integer] x
    # @return [Array<Integer>] column
    def column(x)
      src.ysize.times.map { |y| src[x, y] }
    end

    # Samples all data in row +y+
    #
    # @param [Integer] y
    # @return [Array<Integer>] row
    def row(y)
      src.xsize.times.map { |x| src[x, y] }
    end

    # Rotates the +src+ data clockwise
    #
    # @return [Object] rotated object
    private def rotate_cw
      result = factory2.new(ysize, xsize, default: default)
      ys = ysize - 1
      src.iter.each_with_xy do |n, x, y|
        result[ys - y, x] = n
      end
      result
    end

    # Rotates the +src+ data anti-clockwise
    #
    # @return [Object] rotated object
    private def rotate_ccw
      result = factory2.new(ysize, xsize, default: default)
      xs = xsize - 1
      src.iter.each_with_xy do |n, x, y|
        result[y, xs - x] = n
      end
      result
    end

    # Flips the +src+ data by 180*
    #
    # @return [Object] flipped object
    private def rotate_flip
      result = factory2.new(xsize, ysize, default: default)
      xs, ys = xsize - 1, ysize - 1
      src.iter.each_with_xy do |n, x, y|
        result[xs - x, ys - y] = n
      end
      result
    end

    # Rotate the +src+ data, returns a new object with the rotated data
    #
    # @param [Integer] angle
    # @return [Object]
    def rotate(angle)
      case angle % 360
      when 0   then dup
      when 90  then rotate_cw
      when 180 then rotate_flip
      when 270 then rotate_ccw
      else
        raise RuntimeError, "unsupported rotation angle #{angle}"
      end
    end
  end
end
