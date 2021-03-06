require 'moon-serializable/load'
require 'data_bags/n_data'
require 'data_bags/matrix_like/iterator_base'

module Moon
  #   aka. Table3
  class DataMatrix
    class Iterator
      attr_reader :src

      def initialize(src)
        @src = src
      end

      def each(&block)
        src.blob.each(&block)
      end

      # @return [self]
      def each_with_xyz
        src.zsize.times do |z|
          src.ysize.times do |y|
            src.xsize.times do |x|
              yield src.blob[x + y * src.xsize + z * src.xsize * src.ysize], x, y, z
            end
          end
        end
      end
    end

    include Serializable::Properties
    include Serializable
    include NData
    include MatrixLike

    # @!group Properties
    # @!attribute xsize
    #   @return [Integer] number of columns in the matrix
    property_accessor :xsize
    # @!attribute ysize
    #   @return [Integer] number of rows in the matrix
    property_accessor :ysize
    # @!attribute zsize
    #   @return [Integer] number of layers in the matrix
    property_accessor :zsize
    # @!attribute size
    #   @return [Integer] xsize * ysize * zsize
    property_accessor :size
    # @!attribute data
    #   @return [Array<Integer>] underlaying Array of data
    #   @api
    property_accessor :data
    # @!attribute default
    #   @return [Integer]
    property_accessor :default
    # @!endgroup

    # @param [Integer] xsize
    # @param [Integer] ysize
    # @param [Integer] zsize
    def initialize(xsize, ysize, zsize, options = {})
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @zsize = zsize.to_i
      @default = options.fetch(:default, 0)
      create_data
      yield self if block_given?
    end

    # Recalculates the internal data size
    private def recalculate_size
      @size = @xsize * @ysize * @zsize
    end

    # Ruby's copy initializer
    #
    # @param [DataMatrix] org
    def initialize_copy(org)
      super org
      create_data
      map_with_xyz do |_, x, y, z|
        org.blob[x + y * @xsize + z * @xsize * @ysize]
      end
    end

    # @param [Integer] nxsize
    # @param [Integer] nysize
    # @param [Integer] nzsize
    def resize(nxsize, nysize, nzsize)
      oxsize, oysize, ozsize = xsize, ysize, zsize
      @xsize, @ysize, @zsize = nxsize, nysize, nzsize
      old_data = @data
      create_data
      map_with_xyz do |n, x, y, z|
        if x < oxsize && y < oysize && z < ozsize
          old_data[x + y * oxsize + z * oxsize * oysize]
        else
          @default
        end
      end
    end

    # @return [Moon::Vector3]
    def sizes
      Vector3.new xsize, ysize, zsize
    end

    # @return [Moon::Rect]
    def rect
      Rect.new 0, 0, xsize, ysize
    end

    # @return [Moon::Cuboid]
    def cuboid
      Cuboid.new 0, 0, 0, xsize, ysize, zsize
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @return [Boolean]
    def contains?(x, y, z)
      return ((x >= 0) && (x < @xsize)) &&
             ((y >= 0) && (y < @ysize)) &&
             ((z >= 0) && (z < @zsize))
    end

    # Given a 3d position, calculates the data index
    #
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @return [Integer]
    private def calc_index(x, y, z)
      x + y * @xsize + z * @xsize * @ysize
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @return [Integer]
    def [](x, y, z)
      x = x.to_i
      y = y.to_i
      z = z.to_i
      return @default unless contains?(x, y, z)
      @data[calc_index(x, y, z)] || @default
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Integer] n  Value
    def []=(x, y, z, n)
      x = x.to_i
      y = y.to_i
      z = z.to_i
      n = n.to_i
      return unless contains?(x, y, z)
      @data[calc_index(x, y, z)] = n
    end

    # Initializes and returns an Iterator
    #
    # @return [Interator]
    def iter
      @iter ||= Iterator.new(self)
    end

    # @return [self]
    def map_with_xyz
      iter.each_with_xyz do |n, x, y, z|
        index = x + y * @xsize + z * @xsize * @ysize
        @data[index] = yield n, x, y, z
      end
    end

    # @return [String]
    def to_s
      result = ''
      @zsize.times do |z|
        @ysize.times do |y|
          result.concat(blob[y * @xsize + z * @xsize * @ysize, @xsize].join(', '))
          result.concat("\n")
        end
        result.concat("\n")
      end
      result
    end

    # @param [Hash<String, Integer>] data
    # @param [Integer] depth  recursion counter
    # @return [Moon::DataMatrix]
    def self.load(data, depth = 0)
      instance = new data['xsize'], data['ysize'], data['zsize'],
                     default: data['default']
      instance.import data, depth
      instance
    end
  end
end
