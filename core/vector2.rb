#
# moon/core/vector2.rb
#   Everyone loves a Vector class
module Moon
  class Vector2
    include Comparable

    def zero?
      x == 0 && y == 0
    end

    def <=>(other)
      ox, oy = *Vector2.extract(other)
      [ox, oy] <=> [x, y]
    end

    def to_h
      { x: x, y: y }
    end

    def export
      to_h.merge("&class" => self.class.to_s).stringify_keys
    end

    def import(data)
      self.x = data["x"]
      self.y = data["y"]
      self
    end

    def round(*a)
      Vector2.new x.round(*a), y.round(*a)
    end

    def floor
      Vector2.new x.floor, y.floor
    end

    def ceil
      Vector2.new x.ceil, y.ceil
    end

    def abs
      Vector2.new x.abs, y.abs
    end

    def normalize
      m = [x, y].max.to_f
      Vector2.new x / m, y / m
    end

    def cross(other)
      vx, vy = *Vector2.extract(other)
      Vector2.new x * vy, y * vx
    end unless method_defined? :cross

    def rotate(r)
      Vector2.new x * Math.cos(r) - y * Math.sin(r),
                  x * Math.sin(r) + y * Math.cos(r)
    end unless method_defined? :rotate

    def mag
      Math.sqrt x * x + y * y
    end

    def rad
      Math.atan2 y, x
    end

    def rad=(n)
      m = mag
      self.x = m * Math.cos(n)
      self.y = m * Math.sin(n)
    end

    def xy
      dup
    end

    def xy=(other)
      self.x, self.y = *Vector2.extract(other)
    end

    def xyz
      Vector3.new x, y, 0
    end

    def xyz=(other)
      self.x, self.y, _ = *Vector3.extract(other)
    end

    alias :to_vec2 :xy
    alias :to_vec3 :xyz

    def inspect
      "<Moon::Vector2: x=#{x} y=#{y}>"
    end

    alias :to_s :inspect

    def sum
      x + y
    end

    def near?(other, threshold)
      diff = (self - other).abs
      (diff.x <= threshold.x && diff.y <= threshold.y)
    end

    # https://searchcode.com/codesearch/view/561923/
    # Vector2.MoveTowards
    def move_towards(target, distance)
      diff = self - target
      angle = Math.atan2(diff.y, diff.x)
      self - [Math.cos(angle) * distance, Math.sin(angle) * distance]
    end

    def turn_towards(target)
      diff = target - self
      angle = Math.atan2(diff.y, diff.x)
      Vector2.new(Math.cos(angle), Math.sin(angle))
    end

    def distance_from(target)
      (self - target).abs.sum
    end

    def self.polar(m, r)
      new m * Math.cos(r), m * Math.sin(r)
    end

    def self.zero
      new 0.0, 0.0
    end

    def self.load(data)
      new data["x"], data["y"]
    end
  end
end
