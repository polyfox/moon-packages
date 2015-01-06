module Moon #:nodoc
  # http://studiofreya.com/3d-math-and-physics/simple-aabb-vs-aabb-collision-detection/
  class AABB
    # center position
    # @return [Moon::Vector2]
    attr_reader :cpos
    # radii
    # @return [Moon::Vector2]
    attr_reader :rad

    # @param [Moon::Vector2] rad
    # @param [Moon::Vector2] cpos
    def initialize(cpos, rad)
      @cpos = Vector2[cpos]
      @rad = Vector2[rad]
    end

    # @param [Moon::AABB] other
    # @return [Boolean]
    def intersect?(other)
      return false if (@cpos.x - other.cpos.x).abs > (@rad.x + other.rad.x) ||
                      (@cpos.y - other.cpos.y).abs > (@rad.y + other.rad.y)
      true
    end

    # @param [Moon::AABB] other
    # @return [Moon::AABB]
    def &(other)
      rx = (@cpos.x - other.cpos.x)
      ry = (@cpos.y - other.cpos.y)
      self.class.new(Vector2.new(@cpos.x + rx/2, @cpos.y + ry/2),
                     Vector2.new(rx, ry))
    end
  end
end
