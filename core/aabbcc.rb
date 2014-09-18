# http://studiofreya.com/3d-math-and-physics/simple-aabb-vs-aabb-collision-detection/
module Moon
  class AABBCC
    attr_reader :cpos # Vector3  center position
    attr_reader :rad  # Vector3  radii

    ##
    # @param [Moon::Vector3] cpos
    # @param [Moon::Vector3] rad
    def initialize(cpos, rad)
      @cpos = Vector3[cpos]
      @rad = Vector3[rad]
    end

    ##
    # @param [Moon::AABBCC] other
    # @return [Boolean]
    def intersect?(other)
      return false if (@cpos.x - other.cpos.x).abs > (@rad.x + other.rad.x)
      return false if (@cpos.y - other.cpos.y).abs > (@rad.y + other.rad.y)
      return false if (@cpos.z - other.cpos.z).abs > (@rad.z + other.rad.z)
      true
    end

    ##
    # @param [Moon::AABBCC] other
    # @return [Moon::AABBCC]
    def &(other)
      rx = (@cpos.x - other.cpos.x)
      ry = (@cpos.y - other.cpos.y)
      rz = (@cpos.z - other.cpos.z)
      self.class.new(Vector3.new(@cpos.x + rx/2, @cpos.y + ry/2, @cpos.z + rz/2),
                     Vector3.new(rx, ry, rz))
    end
  end
end
