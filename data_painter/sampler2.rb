module Moon #:nodoc:
  # Factories, as their name imply produce Objects. nuff said
  class TableFactory
    def new(xsize, ysize, options = {})
      Table.new(xsize, ysize, options)
    end
  end

  class Sampler2
    # some variation of Table
    attr_reader   :src
    # object factory, the number signifies the dimensions expected
    attr_accessor :factory2

    # @param [*Data2]
    # @param [Hash<Symbol, Object>] options
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
      rx, ry, rw, rh = *Rect.extract(args.size > 1 ? args : args.first)
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
    # @return [Array<Integer>] row
    def column(x)
      src.ysize.times.map { |y| src[x, y] }
    end

    # @param [Integer] y
    # @return [Array<Integer>] row
    def row(y)
      src.xsize.times.map { |x| src[x, y] }
    end
  end
end
