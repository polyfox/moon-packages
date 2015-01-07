module Moon #:nodoc:
  class Table
    # Iterators do not modify the underlying data
    class Iterator
      attr_reader :src

      def initialize(src)
        @src = src
      end

      def each(&block)
        src.data.each(&block)
      end

      def each_row
        xs = src.xsize
        ys.times do |y|
          yield src.data.slice(y * xs, xs), y
        end
      end

      # Iterates and yields each columns data
      # @yield
      def each_column
        xs, ys = src.xsize, src.ysize
        xs.times do |x|
          yield ys.times.map { |i| src.data[x + i * xs] }, x
        end
      end

      def each_with_xy
        xs, ys = src.xsize, src.ysize
        ys.times do |y|
          row = y * xs
          xs.times do |x|
            yield src.data[x + row], x, y
          end
        end
      end
    end

    # A Cursor is used to navigate a Table without having to specify the
    # data position each time.
    class Cursor
      # @return [Moon::Table]
      attr_reader :src
      # @return [Moon::Vector2]
      attr_accessor :position

      # @param [Moon::Table] src
      def initialize(src)
        @position = Vector2.zero
        @src = src
      end

      # Retrieve value at current +position+
      # @overload get
      # @overload get(x, y)
      #   @param [Integer] x
      #   @param [Integer] y
      # @return [Integer]
      def get(*args)
        if args.size > 0
          x, y = *args
          src[position.x + x, position.y + y]
        else
          src[position.x, position.y]
        end
      end
      alias :[] :get

      # Set value at current +position+
      # @overload put(value)
      #   @param [Integer] value  Value to set
      # @overload put(x, y, value)
      #   @param [Integer] x
      #   @param [Integer] y
      #   @param [Integer] value  Value to set
      def put(*args)
        case args.size
        when 1
          src[position.x, position.y] = args.first
        when 3
          x, y, value = *args
          src[position.x + x, position.y + y] = value
        end
      end
      alias :[]= :put
    end

    include Serializable
    include Serializable::PropertyHelper

    # @!group Properties
    # @attribute [r] xsize
    #   @return [Integer]
    attr_reader property(:xsize)
    # @attribute [r] ysize
    #   @return [Integer]
    attr_reader property(:ysize)
    # @attribute [r] size
    #   @return [Integer]
    attr_reader property(:size)
    # @attribute [r] data
    #   @return [Array<Integer>]
    attr_reader property(:data)
    # @attribute default
    #   @return [Integer]
    attr_accessor property(:default)
    # @!endgroup

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
      return if index < 0 || index >= size
      @data[i] = value
    end

    # Set a Table's data from a String and a Dictionary
    #
    # @param [String] str  String to transcode
    # @param [Hash<String, Integer>] dict  Lookup table to transcoding characters
    # @return [self]
    def set_by_dict(str, dict)
      str.split("\n").each do |row|
        row.bytes.each_with_index do |c, i|
          set_by_index(i, dict[c.chr])
        end
      end
      self
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
      "<#{self.class}: xsize=#{xsize} ysize=#{ysize} size=#{size} default=#{default} data=[...]>"
    end

    # @return [Moon::Table]
    def self.load(data, depth = 0)
      instance = new data['xsize'], data['ysize'], default: data['default']
      instance.import data, depth
      instance
    end
  end
end
