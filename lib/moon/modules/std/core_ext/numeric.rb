class Numeric
  def lerp(target, d)
    self + (target - self) * d
  end

  def to_degrees
    57.2957795 * self
  end

  def to_rads
    self / 57.2957795
  end

  def to_vec2
    Vector2.new self, self
  end

  def to_vec3
    Vector3.new self, self, self
  end

  def to_vec4
    Vector4.new self, self, self, self
  end
end
