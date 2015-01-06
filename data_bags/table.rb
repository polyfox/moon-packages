module Moon #:nodoc:
  class Table
    include Serializable
    include Serializable::PropertyHelper

    # @return [Integer]
    attr_reader property(:xsize)
    # @return [Integer]
    attr_reader property(:ysize)
    # @return [Integer]
    attr_reader property(:size)
    # @return [Array<Integer>]
    attr_reader property(:data)
    # @return [Integer]
    attr_accessor property(:default)

    # @param [Integer] xsize
    # @param [Integer] ysize
    # @param [Hash<Symbol, Object>] options
    def initialize(xsize, ysize, options = {})
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @default = options.fetch(:default, 0)
      if options.key?(:data)
        @data = options.fetch(:data)
      else
        create_data
      end
      yield self if block_given?
    end

    #
    private def recalculate_size
      @size = @xsize * @ysize
    end

    #
    private def create_data
      recalculate_size
      @data = Array.new(@size, @default)
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

    # write_data is a variation of change_data, it validates the size of the
    # data set and then replaces the current data with the given
    #
    # @param [Array<Integer>] data_p
    def write_data(data_p)
      if data_p.size > size
        raise Moon::OverflowError, 'given dataset is larger than internal'
      elsif data_p.size < @size
        raise Moon::UnderflowError, 'given dataset is smaller than internal'
      end
      @data.replace(data_p)
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
