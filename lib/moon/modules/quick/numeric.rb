class Numeric
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
