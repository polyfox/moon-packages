module Moon #:nodoc:
  class Table
    # Iterators do not modify the underlying data
    # This iterator has its functions rewritten and optimized specifically for
    # Table
    class Iterator < Tabular::IteratorBase
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

    include Serializable
    include Serializable::PropertyHelper
    include Tabular

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
    # @api
    attr_reader property(:data)
    # @attribute default
    #   @return [Integer]
    attr_accessor property(:default)
    # @!endgroup

    # @param [Integer] xsize
    # @param [Integer] ysize
    # @param [Hash<Symbol, Object>] options
    # @option options [Integer] :default  (0) default value also used as the :fill
    # @option options [Integer] :fill  (:default) value used to fill the data
    # @option options [Boolean] :unitialized  (false) used in place of .alloc (API)
    # @option options [Array<Integer>] :data  data to use for table
    def initialize(xsize, ysize, options = {})
      return if options[:uninitialized]
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @default = options.fetch(:default, 0)
      if options.key?(:data)
        @data = options.fetch(:data).dup
      else
        create_data(options.fetch(:fill, @default))
      end
      yield self if block_given?
    end

    # @api
    private def recalculate_size
      @size = @xsize * @ysize
    end

    # @api
    private def create_data(fill = @default)
      recalculate_size
      @data = Array.new(@size, fill)
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
    # @api
    def change_data(data_p, xsize, ysize)
      @xsize = xsize
      @ysize = ysize
      @data  = data_p
    end

    # write_data is a variation of change_data, it validates the size of the
    # data set and then replaces the current data with the given
    #
    # @param [Array<Integer>] data_p
    # @api
    def write_data(data_p)
      if data_p.size > size
        raise Moon::OverflowError, 'given dataset is larger than internal'
      elsif data_p.size < @size
        raise Moon::UnderflowError, 'given dataset is smaller than internal'
      end
      @data.replace(data_p)
    end

    # Resizes the dataset
    #
    # @param [Integer] nxsize  New xsize
    # @param [Integer] nysize  New ysize
    # @return [self]
    def resize(nxsize, nysize)
      oxsize, oysize = xsize, ysize
      @xsize, @ysize = nxsize, nysize
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
    # @return [Integer]
    def [](x, y)
      x = x.to_i; y = y.to_i
      return @default unless contains?(x, y)
      @data[x + y * @xsize]
    end

    # Retrieve a value from the internal data at (index)
    #
    # @param [Integer] index
    # @return [Integer] value Value at index
    def get_by_index(index)
      return @default if index < 0 || index >= size
      @data[index]
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] n
    def []=(x, y, n)
      x = x.to_i; y = y.to_i; n = n.to_i
      return unless contains?(x, y)
      @data[x + y * @xsize] = n
    end

    # Because sometimes its too damn troublesome to convert an index to the
    # proper coords
    #
    # @param [Integer] i
    # @param [Integer] value
    def set_by_index(index, value)
      return if index < 0 || index >= size
      @data[index] = value
    end

    # Initializes and returns an Iterator
    #
    # @return [Interator]
    def iter
      @iter ||= Iterator.new(self)
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
