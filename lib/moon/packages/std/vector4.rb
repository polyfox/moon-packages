module Moon
  class Vector4
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y
    add_property :z
    add_property :w

    # @return [Float]
    def sum
      x + y + z + w
    end

    def zero?
      x == 0 && y == 0 && z == 0 && w == 0
    end

    def xy
      Vector2.new x, y
    end

    def xy=(other)
      self.x, self.y = *Vector2.extract(other)
    end

    def zw
      Vector2.new z, w
    end

    def zw=(other)
      self.z, self.w = *Vector2.extract(other)
    end

    def xyz
      Vector3.new x, y, z
    end

    def xyz=(other)
      self.x, self.y, self.z = *Vector3.extract(other)
    end

    def xyzw
      dup
    end

    def xyzw=(other)
      self.x, self.y, self.z, self.w = *Vector4.extract(other)
    end

    alias :to_vec2 :xy
    alias :to_vec3 :xyz
    alias :to_vec4 :xyzw

    # @return [String]
    def to_s
      "#{x}, #{y}, #{z}, #{w}"
    end

    def to_h
      { x: x, y: y, z: z, w: w }
    end

    def [](index)
      case index
      when :x, 'x', 0 then x
      when :y, 'y', 1 then y
      when :z, 'z', 2 then z
      when :w, 'w', 3 then w
      end
    end

    def []=(index, value)
      case index
      when :x, 'x', 0 then self.x = value
      when :y, 'y', 1 then self.y = value
      when :z, 'z', 2 then self.z = value
      when :w, 'w', 3 then self.w = value
      end
    end

    def round(*a)
      Vector4.new x.round(*a), y.round(*a), z.round(*a), w.round(*a)
    end

    def floor
      Vector4.new x.floor, y.floor, z.floor, w.floor
    end

    def ceil
      Vector4.new x.ceil, y.ceil, z.ceil, w.ceil
    end

    def abs
      Vector4.new x.abs, y.abs, z.abs, w.abs
    end

    def near?(other, threshold)
      diff = (self - other).abs
      (diff.x <= threshold.x && diff.y <= threshold.y && diff.z <= threshold.z && diff.w <= threshold.w)
    end

    # @return [Moon::Vector4]
    def self.zero
      new 0.0, 0.0, 0.0, 0.0
    end

    # @return [Moon::Vector4]
    def self.load(data, depth = 0)
      new data['x'], data['y'], data['z'], data['w']
    end

    alias :rgb :xyz
    alias :rgb= :xyz=
    alias :rgba :xyzw
    alias :rgba= :xyzw=
  end
end
