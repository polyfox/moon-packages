# An IO class stub, this class is intended to be used as a placeholder for
# a class that uses an IO object.
# Example of such classes would be a logger that logs to an IO.
class NullIO
  def write(*args, &block)
  end

  def print(*args, &block)
  end

  def puts(*args, &block)
  end

  def <<(*args, &block)
  end

  def read(*args, &block)
    nil
  end

  def flush(*args, &block)
    self
  end

  IN = new
  OUT = new
  ERR = new
end
