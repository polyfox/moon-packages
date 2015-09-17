module Moon #:nodoc
  # http://studiofreya.com/3d-math-and-physics/simple-aabb-vs-aabb-collision-detection/
  class AABBCC
    attr_reader :cpos # Vector3  center position
    attr_reader :rad  # Vector3  radii

    # @param [Moon::Vector3] cpos
    # @param [Moon::Vector3] rad
    def initialize(cpos, rad)
      @cpos = Vector3[cpos]
      @rad = Vector3[rad]
    end

    # Does the given AABBCC intersect with this?
    #
    # @param [Moon::AABBCC] other
    # @return [Boolean]
    def intersect?(other)
      return false if (@cpos.x - other.cpos.x).abs > (@rad.x + other.rad.x) ||
                      (@cpos.y - other.cpos.y).abs > (@rad.y + other.rad.y) ||
                      (@cpos.z - other.cpos.z).abs > (@rad.z + other.rad.z)
      true
    end

    # Creates an intersected AABBCC from the given (other)
    #
    # @param [Moon::AABBCC] other
    # @return [Moon::AABBCC]
    def &(other)
      return nil unless intersect?(other)
      rx = other.cpos.x - @cpos.x
      ry = other.cpos.y - @cpos.y
      rz = other.cpos.z - @cpos.z
      AABBCC.new(Vector3.new(@cpos.x + rx/2, @cpos.y + ry/2, @cpos.z + rz/2),
                 Vector3.new(rx.abs, ry.abs, rz.abs))
    end
  end
end
