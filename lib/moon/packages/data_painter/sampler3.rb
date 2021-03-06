module Moon
  # A Sampler3 is meant for wrapping 2d data objects and producing new 3d data
  # objects.
  # Samplers do not modify the underlying data.
  class Sampler3
    # @!attribute [r] src
    #   @return [MatrixLike]
    attr_reader   :src
    # @!attribute [r] factory2
    #   @return [Object]
    attr_accessor :factory2
    # @!attribute [r] factory3
    #   @return [Object]
    attr_accessor :factory3

    # @param [Object] src
    # @param [Hash<Symbol, Object>] options
    #   @option options [#new] factory3
    def initialize(src, options = {})
      # Sources are expected to support:
      #   [](x, y, z)
      #   []=(x, y, z, value)
      #   xsize
      #   ysize
      #   zsize
      @src = src
      # A factory is used to produce objects of the same type as the src
      # wrapped by the Sampler, the Factory uses a common API, and knows
      # how to create the object from the parameters
      @factory2 = options.fetch(:factory2) { Table }
      @factory3 = options.fetch(:factory3) { DataMatrix }
    end

    # Gets data at provided position.
    #
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @return [Integer]
    def [](x, y, z)
      src[x, y, z]
    end

    ##
    # @return [*Data3]
    def subsample(*args)
      cx, cy, cz, cw, ch, cd = *Cuboid.extract(args.singularize)
      result = factory3.new(cw, ch, cd, default: src.default)
      result.zsize.times do |z|
        dz = cz + z
        result.ysize.times do |y|
          dy = cy + y
          result.xsize.times do |x|
            result[x, y, z] = src[x + cx, dy, dz]
          end
        end
      end
      result
    end

    ##
    # @return [*Data2]
    def layer(z)
      table = factory2.new(src.xsize, src.ysize, default: src.default)
      table.ysize.times do |y|
        table.xsize.times do |x|
          table[x, y] = src[x, y, z]
        end
      end
      table
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @return [Enumerator]
    def pillar(x, y)
      return to_enum(:pillar, x, y) unless block_given?
      src.zsize.times.each { |z| yield src[x, y, z] }
    end

    ##
    # @param [Integer] x
    # @param [Integer] z
    # @return [Enumerator]
    def column(x, z)
      return to_enum(:column, x, z) unless block_given?
      src.ysize.times.each { |y| yield src[x, y, z] }
    end

    ##
    # @param [Integer] y
    # @param [Integer] z
    # @return [Enumerator]
    def row(y, z)
      return to_enum(:row, y, z) unless block_given?
      src.xsize.times.each { |x| yield src[x, y, z] }
    end
  end
end
