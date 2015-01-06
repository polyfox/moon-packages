#   aka. Table3
module Moon
  class DataMatrix
    include Serializable

    attr_reader :xsize
    attr_reader :ysize
    attr_reader :zsize
    attr_reader :data
    attr_accessor :default

    def initialize(xsize, ysize, zsize, options = {})
      @xsize = xsize.to_i
      @ysize = ysize.to_i
      @zsize = zsize.to_i
      @default = options.fetch(:default, 0)
      create_data
      yield self if block_given?
    end

    private def create_data
      @data = Array.new(@xsize * @ysize * @zsize, @default)
    end

    def initialize_copy(org)
      super org
      create_data
      map_with_xyz { |_, x, y, z| org.data[x + y * @xsize + z * @xsize * @ysize] }
    end

    def size
      Vector3.new @xsize, @ysize, @zsize
    end

    def rect
      Rect.new 0, 0, @xsize, @ysize
    end

    def cuboid
      Cuboid.new 0, 0, 0, @xsize, @ysize, @zsize
    end

    def subsample(*args)
      cx, cy, cz, cw, ch, cd = *Cuboid.extract(args.size > 1 ? args : args.first)
      result = self.class.new(cw, ch, cd, default: @default)
      result.zsize.times do |z|
        dz = cz + z
        result.ysize.times do |y|
          dy = cy + y
          result.xsize.times do |x|
            result[x, y, z] = self[x + cx, dy, dz]
          end
        end
      end
      result
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

    def each
      @data.each do |layer|
        layer.each do |row|
          row.each do |n|
            yield n
          end
        end
      end
    end

    def each_with_xyz
      @zsize.times do |z|
        @ysize.times do |y|
          @xsize.times do |x|
            yield @data[x + y * @xsize + z * @xsize * @ysize], x, y, z
          end
        end
      end
    end

    def map_with_xyz
      each_with_xyz do |n, x, y, z|
        index = x + y * @xsize + z * @xsize * @ysize
        @data[index] = yield n, x, y, z
      end
    end

    def fill(n)
      map_with_xyz { |old_n, x, y, z| n }
    end

    def clear(n=0)
      fill(n)
    end

    def pillar_a(x, y)
      @zsize.times.map { |z| self[x, y, z] }
    end

    def layer(z)
      layer_data = @data[z * @xsize * @ysize, @xsize * @ysize]
      table = Table.new(0, 0)
      table.change_data(layer_data, @xsize, @ysize)
      table
    end

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
      "<#{self.class}: xsize=#{xsize} ysize=#{ysize} zsize=#{zsize} default=#{default} data=[...]>"
    end

    def to_h
      {
        xsize: @xsize,
        ysize: @ysize,
        zsize: @zsize,
        default: @default,
        data: @data
      }
    end

    def set_property(key, value)
      case key.to_s
      when 'xsize' then @xsize = value
      when 'ysize' then @ysize = value
      when 'zsize' then @zsize = value
      when 'default' then @default = value
      when 'data' then @data = value
      end
    end

    def serialization_properties(&block)
      to_h.each(&block)
    end

    def self.load(data, depth = 0)
      instance = new data['xsize'], data['ysize'], data['zsize'],
                     default: data['default']
      instance.import data, depth
      instance
    end
  end
end
