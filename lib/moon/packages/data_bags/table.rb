require 'moon-serializable/load'
require 'data_bags/n_data'
require 'data_bags/tabular/iterator_base'

module Moon
  # A 2 dimensional array used normally for storing Tilemap data or any 2d grid
  # based data such hmaps, image data, passage data.
  class Table
    # Iterators do not modify the underlying data
    # This iterator has its functions rewritten and optimized specifically for
    # Table
    class Iterator < Tabular::IteratorBase
    end

    include Serializable::Properties
    include Serializable
    include NData
    include Tabular

    # @!group Properties
    # @attribute xsize
    #   @return [Integer]
    property_accessor :xsize
    # @attribute ysize
    #   @return [Integer]
    property_accessor :ysize
    # @attribute size
    #   @return [Integer]
    property_accessor :size
    # @attribute data
    #   @return [Array<Integer>]
    # @api
    property_accessor :data
    # @attribute default
    #   @return [Integer]
    property_accessor :default
    # @!endgroup

    # @param [Integer] xsize
    # @param [Integer] ysize
    # @param [Hash<Symbol, Object>] options
    # @option options [Integer] :default  (0) default value also used as the :fill
    # @option options [Boolean] :unitialized  (false) used in place of .alloc (API)
    # @option options [Array<Integer>] :data  data to use for table
    def initialize(xsize, ysize, options = {})
      return if options[:uninitialized]
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @default = options.fetch(:default, 0)
      create_data
      yield self if block_given?
    end

    # @api
    private def recalculate_size
      @size = @xsize * @ysize
    end

    # @param [Moon::Table] org
    # @return [self]
    def initialize_copy(org)
      super org
      create_data
      map_with_xy { |_, x, y| org.blob[x + y * @xsize] }
      self
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

    # Given a 2d position, calculates the data index
    #
    # @param [Integer] x
    # @param [Integer] y
    # @return [Integer]
    private def calc_index(x, y)
      x + y * @xsize
    end

    # @param [Integer] x
    # @param [Integer] y
    # @return [Integer]
    def [](x, y)
      x = x.to_i
      y = y.to_i
      return @default unless contains?(x, y)
      @data[calc_index(x, y)] || @default
    end

    # Retrieve a value from the internal data at (index)
    #
    # @param [Integer] index
    # @return [Integer] value Value at index
    def get_by_index(index)
      return @default if index < 0 || index >= size
      @data[index] || @default
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] n
    def []=(x, y, n)
      x = x.to_i
      y = y.to_i
      n = n.to_i
      return unless contains?(x, y)
      @data[calc_index(x, y)] = n
    end

    # Because sometimes its too damn troublesome to convert an index to the
    # proper coords
    #
    # @param [Integer] index
    # @param [Integer] value
    def set_by_index(index, value)
      return if index < 0 || index >= size
      blob[index] = value
    end

    # Initializes and returns an Iterator
    #
    # @return [Interator]
    def iter
      @iter ||= Iterator.new(self)
    end

    # @return [String]
    def to_s
      @ysize.times.map do |y|
        blob[y * @xsize, @xsize].join(', ')
      end.join("\n")
    end

    # Serialization
    # @return [Moon::Table]
    def self.load(data, depth = 0)
      instance = new nil, nil, uninitialized: true
      instance.import data, depth
      instance
    end
  end
end
