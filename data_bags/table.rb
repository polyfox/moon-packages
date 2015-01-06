module Moon
  class Table
    include Enumerable
    include Serializable

    # @return [Integer]
    attr_reader :xsize
    # @return [Integer]
    attr_reader :ysize
    # @return [Integer]
    attr_accessor :default

    # @param [Integer] xsize
    # @param [Integer] ysize
    # @param [Hash<Symbol, Object>] options
    def initialize(xsize, ysize, options = {})
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @default = options.fetch(:default, 0)
      create_data
      yield self if block_given?
    end

    # @param [Void]
    private def create_data
      @data = Array.new(@xsize * @ysize, @default)
    end

    # @param [Moon::Table] org
    def initialize_copy(org)
      super org
      create_data
      map_with_xy { |_, x, y| org.data[x + y * @xsize] }
    end

    # @param [Array<Integer>] data_p
    # @param [Integer] xsize
    # @param [Integer] ysize
    def change_data(data_p, xsize, ysize)
      @xsize = xsize
      @ysize = ysize
      @data  = data_p
    end

    # @param [Integer] xsize
    # @param [Integer] ysize
    def resize(xsize, ysize)
      oxsize, oysize = *size
      @xsize, @ysize = xsize, ysize
      old_data = @data
      create_data
      map_with_xy do |n, x, y|
        if x < oxsize && y < oysize
          old_data[x + y * oxsize]
        else
          @default
        end
      end
    end

    # @param [Integer] x
    # @param [Integer] y
    def in_bounds?(x, y)
      return ((x >= 0) && (x < xsize)) &&
             ((y >= 0) && (y < ysize))
    end

    # @param [Integer] x
    # @param [Integer] y
    def [](x, y)
      x = x.to_i; y = y.to_i
      return @default unless in_bounds?(x, y)
      @data[x + y * @xsize]
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] n
    def []=(x, y, n)
      x = x.to_i; y = y.to_i; n = n.to_i
      return unless in_bounds?(x, y)
      @data[x + y * @xsize] = n
    end

    # Because sometimes its too damn troublesome to convert an index to the
    # proper coords
    #
    # @param [Integer] i
    # @param [Integer] value
    def set_by_index(i, value)
      self[i % xsize, i / xsize] = value
    end

    #
    def each
      @data.each do |x|
        yield x
      end
    end

    #
    def each_row
      xsize.times do |x|
        yield @data[x * @xsize, @xsize]
      end
    end

    #
    def each_with_xy
      ysize.times do |y|
        xsize.times do |x|
          yield @data[x + y * @xsize], x, y
        end
      end
    end

    #
    def map_with_xy
      each_with_xy do |n, x, y|
        index = x + y * @xsize
        @data[index] = yield @data[index], x, y
      end
    end

    # @return [Moon::Vector2]
    def size
      Moon::Vector2.new xsize, ysize
    end

    # @return [Moon::Rect]
    def rect
      Moon::Rect.new 0, 0, xsize, ysize
    end

    # @return [Moon::Cuboid]
    def cuboid
      Moon::Cuboid.new 0, 0, 0, xsize, ysize, 1
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
      result = self.class.new(rw, rh, default: default)
      result.ysize.times do |y|
        dy = y + ry
        result.xsize.times do |x|
          result[x, y] = self[x + rx, dy]
        end
      end
      result
    end

    # @param [Integer] n
    def fill(n)
      map_with_xy { |old_n, x, y| n }
    end

    # @overload map_rect(rect)
    #   @param [Moon::Rect, Array<Integer>] rect
    # @overload map_rect(x, y, width, height)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] width
    #   @param [Integer] height
    # @return [self]
    def map_rect(*args)
      x, y, w, h = *Rect.extract(args.size > 1 ? args : args.first)
      h.times do |j|
        w.times do |i|
          self[x + i, y + j] = yield x, y
        end
      end
      self
    end

    # @param [Integer] x  x-coord
    # @param [Integer] y  y-coord
    # @param [Integer] w  width
    # @param [Integer] h  height
    # @param [Integer] v  value
    # @return [self]
    def fill_rect_xywh(x, y, w, h, v)
      map_rect(x, y, w, h) { v }
    end

    # @overload fill_rect(rect, value)
    #   @param [Moon::Rect, Array<Integer>] rect
    #   @param [Integer] value
    # @overload fill_rect(x, y, width, height, value)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] width
    #   @param [Integer] height
    #   @param [Integer] value
    # @return [self]
    def fill_rect(*args)
      case args.size
      when 2
        r, n = *args
        fill_rect_xywh(r.x, r.y, r.w, r.h, n)
      when 5
        fill_rect_xywh(*args)
      else
        raise ArgumentError,
              "wrong argument count #{args.size} (expected 2:(rect, value) or 5:(x, y, w, h, value))"
      end
    end

    # @param [Integer] n
    def clear(n = 0)
      fill(n)
    end

    # @param [Integer] n
    # @return [Array<Integer>] row
    def row(y)
      @data[y * @xsize, @xsize]
    end

    # @return [Integer]
    def row_count
      ysize
    end

    # @return [String]
    def to_s
      result = ''
      @ysize.times do |y|
        result.concat(@data[y * @xsize, @xsize].join(', '))
        result.concat("\n")
      end
      return result
    end

    # @return [String]
    def inspect
      "<#{self.class}: xsize=#{xsize} ysize=#{ysize} default=#{default} data=[...]>"
    end

    # @return [Hash<Symbol, Integer>]
    def to_h
      {
        xsize: @xsize,
        ysize: @ysize,
        default: @default,
        data: @data
      }
    end

    def set_property(key, value)
      case key.to_s
      when 'xsize'   then @xsize = value
      when 'ysize'   then @ysize = value
      when 'default' then @default = value
      when 'data'    then @data = value
      end
    end

    def serialization_properties(&block)
      to_h.each(&block)
    end

    # @return [Moon::Table]
    def self.load(data, depth = 0)
      instance = new data['xsize'], data['ysize'], default: data['default']
      instance.import data, depth
      instance
    end
  end
end
