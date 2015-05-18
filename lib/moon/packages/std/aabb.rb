module Moon
  # http://studiofreya.com/3d-math-and-physics/simple-aabb-vs-aabb-collision-detection/
  class AABB
    # @!attribute [r] cpos  center position
    # @return [Moon::Vector2]
    attr_reader :cpos

    # @!attribute [r] rad  radii
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

    # @todo
    def self.create_encompassing(aabbs)
      cpos = Vector2.zero
      rad = Vector2.zero
      aabbs.each do |aabb|
        #
      end
      new cpos, rad
    end
  end
end
