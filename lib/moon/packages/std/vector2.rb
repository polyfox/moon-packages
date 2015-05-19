module Moon
  class Vector2
    include Serializable::Properties
    include Serializable

    add_property :x
    add_property :y

    # @return [Float]
    def sum
      x + y
    end

    # @return [Boolean] is the vector zero?
    def zero?
      x == 0.0 && y == 0.0
    end

    # @return [Moon::Vector2]
    def xy
      dup
    end

    # @param [Moon::Vector2] other
    def xy=(other)
      self.x, self.y = *Vector2.extract(other)
    end

    alias :to_vec2 :xy

    # @return [String]
    def to_s
      "#{x}, #{y}"
    end

    # @return [Hash<Symbol, Float>]
    def to_h
      { x: x, y: y }
    end

    def [](index)
      case index
      when :x, 'x', 0 then x
      when :y, 'y', 1 then y
      end
    end

    def []=(index, value)
      case index
      when :x, 'x', 0 then self.x = value
      when :y, 'y', 1 then self.y = value
      end
    end

    # @return [Vector2]
    def round(*a)
      Vector2.new x.round(*a), y.round(*a)
    end

    # @return [Vector2]
    def floor
      Vector2.new x.floor, y.floor
    end

    # @return [Vector2]
    def ceil
      Vector2.new x.ceil, y.ceil
    end

    # @return [Vector2]
    def abs
      Vector2.new x.abs, y.abs
    end

    # @return [Vector2]
    def perp
      Vector2.new(-y, x)
    end

    # @return [Vector2]
    def rperp
      Vector2.new(y, -x)
    end

    # @return [Vector2]
    def project(v)
      v * (dot(v) / v.dot(v))
    end

    # @return [Float]
    def lengthsq
      dot(self)
    end

    # @return [Float]
    def angle
      Math.atan2(y, x)
    end

    # @param [Float] n
    def angle=(n)
      l = length
      self.x = l * Math.cos(n)
      self.y = l * Math.sin(n)
    end

    def slerp(v, t)
      omega = [[normalize.dot(v.normalize), 1.0].min, -1.0].max
      if omega < 1e-3
        lerp(v, t)
      else
        denom = 1.0 / Math.sin(omega)
        (self * ((Math.sin(1.0 - t) * omega) * denom)) +
        (v * ((Math.sin(t) * omega) * denom))
      end
    end

    # @param [Moon::Vector2] other
    # @param [Float] dist
    def near?(other, dist)
      length = (self - other).length
      length < (dist * dist)
    end

    # https://searchcode.com/codesearch/view/561923/
    # Vector2.MoveTowards
    def move_towards(target, distance)
      angle = (target - self).angle
      self + Vector2.new(Math.cos(angle) * distance, Math.sin(angle) * distance)
    end

    def turn_towards(target)
      angle = (target - self).angle
      Vector2.new(Math.cos(angle), Math.sin(angle))
    end

    def self.for_angle(a)
      new Math.cos(a), Math.sin(a)
    end

    # @return [Moon::Vector2]
    def self.zero
      new 0.0, 0.0
    end

    def self.load(data, depth = 0)
      new data['x'], data['y']
    end
  end
end
