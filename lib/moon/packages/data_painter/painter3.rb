module Moon
  class Painter3
    # @return [Moon::DataMatrix]
    attr_reader :target

    # @param [Moon::DataMatrix] target
    def initialize(target)
      @target = target
    end

    # Replace all the data with (n)
    #
    # @param [Integer] n
    def fill(n)
      target.map_with_xyz { |_, _, _, _| n }
    end

    # Replace all data with the default
    #
    # @param [Integer] n
    def clear(n = nil)
      fill(n || @target.default)
    end

    # @overload map_cube(cube)
    #   @param [Moon::Cube, Array[6]<Integer>] cube
    # @overload map_cube(x, y, z, w, h, depth)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] z
    #   @param [Integer] w
    #   @param [Integer] h
    #   @param [Integer] depth
    # @yieldparam [Integer] current_value  Current value at this position
    # @yieldparam [Integer] x  x-Coord
    # @yieldparam [Integer] y  y-Coord
    # @yieldparam [Integer] z  z-Coord
    # @yieldreturn [Integer] New value to set
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

    # @param [Integer] x  x-Coord
    # @param [Integer] y  y-Coord
    # @param [Integer] z  z-Coord
    # @param [Integer] w  Width
    # @param [Integer] h  Height
    # @param [Integer] d  Depth
    # @param [Integer] v  Value
    # @return [self]
    def fill_cube_xyzwhd(x, y, z, w, h, d, v)
      map_cube(x, y, z, w, h, d) { v }
    end

    # @overload fill_cube(cube, value)
    #   @param [Moon::Cube, Array[6]<Integer>] cube  Selection
    #   @param [Integer] value  Value
    # @overload fill_cube(x, y, z, w, h, d, v)
    #   @param [Integer] x  x-Coord
    #   @param [Integer] y  y-Coord
    #   @param [Integer] z  z-Coord
    #   @param [Integer] w  Width
    #   @param [Integer] h  Height
    #   @param [Integer] d  Depth
    #   @param [Integer] v  Value
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
