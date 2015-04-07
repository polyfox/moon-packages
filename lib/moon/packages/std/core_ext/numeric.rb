class Numeric
  def lerp(target, d)
    self + (target - self) * d
  end

  # @return [Float]
  def to_degrees
    57.2957795 * self
  end

  # @return [Float]
  def to_rads
    self / 57.2957795
  end

  # @return [Moon::Vector1]
  def to_vec1
    Moon::Vector1.new self
  end

  # @return [Moon::Vector2]
  def to_vec2
    Moon::Vector2.new self, self
  end

  # @return [Moon::Vector3]
  def to_vec3
    Moon::Vector3.new self, self, self
  end

  # @return [Moon::Vector4]
  def to_vec4
    Moon::Vector4.new self, self, self, self
  end

  #
  # @param [Numeric] n
  # @return [Numeric]
  def max(n)
    if n > self
      n
    else
      self
    end
  end

  #
  # @param [Numeric] n
  # @return [Numeric]
  def min(n)
    if n > self
      n
    else
      self
    end
  end

  #
  # @param [Numeric] a
  # @param [Numeric] b
  # @return [Numeric]
  def clamp(a, b)
    if self < a
      a
    elsif self > b
      b
    else
      self
    end
  end
end
