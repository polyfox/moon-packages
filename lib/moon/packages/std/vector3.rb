module Moon
  class Vector3
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
    add_property :z

    # @return [Float]
    def sum
      x + y + z
    end

    # @return [Boolean]
    def zero?
      x == 0 && y == 0 && z == 0
    end

    def xy
      Vector2.new x, y
    end

    def xy=(other)
      self.x, self.y = *Vector2.extract(other)
    end

    def xyz
      self
    end

    def xyz=(other)
      self.x, self.y, self.z = *Vector3.extract(other)
    end

    alias :to_vec2 :xy
    alias :to_vec3 :xyz

    # @return [String]
    def to_s
      "#{x},#{y},#{z}"
    end

    def to_h
      { x: x, y: y, z: z }
    end

    def [](index)
      case index
      when :x, 'x', 0 then x
      when :y, 'y', 1 then y
      when :z, 'z', 2 then z
      end
    end

    def []=(index, value)
      case index
      when :x, 'x', 0 then self.x = value
      when :y, 'y', 1 then self.y = value
      when :z, 'z', 2 then self.z = value
      end
    end

    # @return [Moon::Vector3]
    def round(*a)
      Vector3.new x.round(*a), y.round(*a), z.round(*a)
    end

    # @return [Moon::Vector3]
    def floor
      Vector3.new x.floor, y.floor, z.floor
    end

    # @return [Moon::Vector3]
    def ceil
      Vector3.new x.ceil, y.ceil, z.ceil
    end

    # @return [Moon::Vector3]
    def abs
      Vector3.new x.abs, y.abs, z.abs
    end

    # @return [Moon::Vector3]
    def project(v)
      v * (dot(v) / v.dot(v))
    end

    # @return [Float]
    def lengthsq
      dot(self)
    end

    def near?(other, threshold)
      diff = (self - other).abs
      (diff.x <= threshold.x && diff.y <= threshold.y && diff.z <= threshold.z)
    end

    # @return [Moon::Vector3]
    def move_towards(target, distance)
      diff = target - self
      angle = Math.atan2(diff.y, diff.x)
      self + Vector3.new(Math.cos(angle) * distance, Math.sin(angle) * distance, 0)
    end

    # @return [Moon::Vector3]
    def turn_towards(target)
      diff = target - self
      angle = Math.atan2(diff.y, diff.x)
      Vector3.new(Math.cos(angle), Math.sin(angle), 0)
    end

    # @return [Moon::Vector3]
    def self.zero
      new 0.0, 0.0, 0.0
    end

    # @return [Moon::Vector3]
    def self.load(data, depth = 0)
      new data['x'], data['y'], data['z']
    end

    alias :rgb :xyz
    alias :rgb= :xyz=
  end
end
