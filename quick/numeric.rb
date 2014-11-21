class Numeric
  def max(n)
    if n > self
      n
    else
      self
    end
  end

  def min(n)
    if n > self
      n
    else
      self
    end
  end
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
