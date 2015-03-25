module Moon #:nodoc:
  # Factories, as their name imply produce Objects. nuff said
  class TableFactory
    # @param [Integer] xsize
    # @param [Integer] ysize
    # @param [Hash] options
    # @return [Table]
    def new(xsize, ysize, options = {})
      Table.new xsize, ysize, options
    end
  end

  class Sampler2
    # some variation of Table
    attr_reader   :src
    # object factory, the number signifies the dimensions expected
    attr_accessor :factory2

    # @param [*Data2]
    # @param [Hash<Symbol, Object>] options
    #   @option options [#new] factory2
    def initialize(src, options = {})
      @src = src
      @factory2 = options.fetch(:factory2) { TableFactory.new }
    end

    # @param [Integer] x
    # @param [Integer] y
    # @return [Integer]
    def [](x, y)
      src[x, y]
    end

    # @overload subsample(rect)
    #   @param [Moon::Rect, Array<Integer>] rect
    # @overload subsample(x, y, w, h)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] w
    #   @param [Integer] h
    # @return [Moon::Table]
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

    # @param [Integer] x
    # @return [Array<Integer>] column
    def column(x)
      src.ysize.times.map { |y| src[x, y] }
    end

    # @param [Integer] y
    # @return [Array<Integer>] row
    def row(y)
      src.xsize.times.map { |x| src[x, y] }
    end

    # @return [*Data2]
    private def rotate_cw
      result = factory2.new(ysize, xsize, default: default)
      ys = ysize - 1
      src.iter.each_with_xy do |n, x, y|
        result[ys - y, x] = n
      end
      result
    end

    # @return [*Data2]
    private def rotate_ccw
      result = factory2.new(ysize, xsize, default: default)
      xs = xsize - 1
      src.iter.each_with_xy do |n, x, y|
        result[y, xs - x] = n
      end
      result
    end

    # @return [*Data2]
    private def rotate_flip
      result = factory2.new(xsize, ysize, default: default)
      xs, ys = xsize - 1, ysize - 1
      src.iter.each_with_xy do |n, x, y|
        result[xs - x, ys - y] = n
      end
      result
    end

    ##
    # Rotate the Table data, returns a new Table with the rotated data
    #
    # @param [Integer] angle
    # @return [*Data2]
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
