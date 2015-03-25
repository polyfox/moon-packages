module Moon #:nodoc:
  #   aka. Table3
  class DataMatrix
    class Iterator
      attr_reader :src

      def initialize(src)
        @src = src
      end

      def each(&block)
        src.data.each(&block)
      end

      # @return [self]
      def each_with_xyz
        src.zsize.times do |z|
          src.ysize.times do |y|
            src.xsize.times do |x|
              yield src.data[x + y * src.xsize + z * src.xsize * src.ysize], x, y, z
            end
          end
        end
      end
    end

    include Serializable
    include Serializable::PropertyHelper
    include MatrixLike

    # @!group Properties
    # @attribute [r] xsize
    #   @return [Integer]
    attr_reader property(:xsize)
    # @attribute [r] ysize
    #   @return [Integer]
    attr_reader property(:ysize)
    # @attribute [r] zsize
    #   @return [Integer]
    attr_reader property(:zsize)
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
    # @param [Integer] zsize
    def initialize(xsize, ysize, zsize, options = {})
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @zsize = zsize.to_i
      @default = options.fetch(:default, 0)
      create_data
      yield self if block_given?
    end

    #
    private def recalculate_size
      @size = @xsize * @ysize * @zsize
    end

    #
    private def create_data
      recalculate_size
      @data = Array.new(@size, @default)
    end

    # @param [DataMatrix] org
    def initialize_copy(org)
      super org
      create_data
      map_with_xyz { |_, x, y, z| org.data[x + y * @xsize + z * @xsize * @ysize] }
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
    # @param [Integer] zsize
    def resize(xsize, ysize, zsize)
      oxsize, oysize, ozsize = *size
      @xsize, @ysize, @zsize = xsize, ysize, zsize
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

    def size
      Vector3.new xsize, ysize, zsize
    end

    def rect
      Rect.new 0, 0, xsize, ysize
    end

    def cuboid
      Cuboid.new 0, 0, 0, xsize, ysize, zsize
    end

    def in_bounds?(x, y, z)
      return ((x >= 0) && (x < @xsize)) &&
             ((y >= 0) && (y < @ysize)) &&
             ((z >= 0) && (z < @zsize))
    end

    def [](x, y, z)
      x = x.to_i; y = y.to_i; z = z.to_i
      return @default unless in_bounds?(x, y, z)
      @data[x + y * @xsize + z * @xsize * @ysize]
    end

    def []=(x, y, z, n)
      x = x.to_i; y = y.to_i; z = z.to_i; n = n.to_i
      return unless in_bounds?(x, y, z)
      @data[x + y * @xsize + z * @xsize * @ysize] = n
    end

    # Initializes and returns an Iterator
    #
    # @return [Interator]
    def iter
      @iter ||= Iterator.new(self)
    end

    def map_with_xyz
      each_with_xyz do |n, x, y, z|
        index = x + y * @xsize + z * @xsize * @ysize
        @data[index] = yield n, x, y, z
      end
    end

    def to_s
      result = ''
      @zsize.times do |z|
        @ysize.times do |y|
          result.concat(@data[y * @xsize + z * @xsize * @ysize, @xsize].join(', '))
          result.concat("\n")
        end
        result.concat("\n")
      end
      return result
    end

    # @return [String]
    def inspect
      "<#{self.class}: xsize=#{xsize} ysize=#{ysize} zsize=#{zsize} size=#{size} default=#{default} data=[...]>"
    end

    def self.load(data, depth = 0)
      instance = new data['xsize'], data['ysize'], data['zsize'],
                     default: data['default']
      instance.import data, depth
      instance
    end
  end
end
