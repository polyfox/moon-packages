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
      return nil unless intersect?(other)
      rx = other.cpos.x - @cpos.x
      ry = other.cpos.y - @cpos.y
      AABB.new(Vector2.new(@cpos.x + rx/2, @cpos.y + ry/2),
               Vector2.new(rx.abs, ry.abs))
    end

    # Creates a bounding box from the given AABBs
    #
    # @param [Array<AABB>] aabbs
    # @return [Array<Float>] bounding box
    def self.bb_from(aabbs)
      x1, y1, x2, y2 = nil, nil, nil, nil
      aabbs.each do |aabb|
        p1 = aabb.cpos - aabb.rad
        p2 = aabb.cpos + aabb.rad

        x1 ||= p1.x
        y1 ||= p1.y
        x2 ||= p2.x
        y2 ||= p2.y

        x1 = p1.x if p1.x < x1
        y1 = p1.y if p1.y < y1

        x2 = p2.x if p2.x > x2
        y2 = p2.y if p2.y > y2
      end

      return x1, y1, x2, y2
    end

    # Creates an encompasing AABB from the given AABBs
    #
    # @param [Array<AABB>] aabbs
    # @return [AABB]
    def self.create_encompassing(aabbs)
      return new 0, 0 if aabbs.empty?

      x1, y1, x2, y2 = bb_from(aabbs)

      cpos = Vector2.new(x1 + (x2 - x1) / 2, y1 + (y2 - y1) / 2)
      rad = Vector2.new((x2 - x1) / 2, (y2 - y1) / 2)

      new cpos, rad
    end
  end
end
