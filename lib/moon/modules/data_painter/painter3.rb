module Moon #:nodoc:
  class Painter3
    attr_reader :target

    def initialize(target)
      @target = target
    end

    def fill(n)
      target.map_with_xyz { |_, _, _, _| n }
    end

    def clear(n = 0)
      fill(n)
    end

    # @overload map_cube(cube)
    #   @param [Moon::Cube, Array[6]<Integer>] cube
    # @overload map_cube(x, y, width, height)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] z
    #   @param [Integer] width
    #   @param [Integer] height
    #   @param [Integer] depth
    # @return [self]
    def map_cube(*args)
      x, y, z, w, h, d = *Cube.extract(args.size > 1 ? args : args.first)
      d.times do |k|
        h.times do |j|
          w.times do |i|
            target[x + i, y + j, z + k] = yield target[x + i, y + j, z + k], i, j, k
          end
        end
      end
      self
    end

    # @param [Integer] x  x-coord
    # @param [Integer] y  y-coord
    # @param [Integer] z  z-coord
    # @param [Integer] w  width
    # @param [Integer] h  height
    # @param [Integer] d  depth
    # @param [Integer] v  value
    # @return [self]
    def fill_cube_xyzwhd(x, y, z, w, h, d, v)
      map_cube(x, y, z, w, h, d) { v }
    end

    # @param [Moon::Cube] cube
    # @param [Integer] value
    def fill_cube(*args)
      case args.size
      when 2
        cube, value = *args
        x, y, z, w, h, d = *cube
        fill_cube_xyzwhd(x, y, z, w, h, d, value)
      when 7
        fill_cube_xyzwhd(*args)
      else
        raise ArgumentError,
              "wrong argument count #{args.size} (expected 2:(rect, value) or 5:(x, y, w, h, value))"
      end
    end
  end
end
