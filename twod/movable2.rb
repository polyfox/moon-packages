module Movable2
  def move_distance
    1
  end

  def moveto(*args)
    self.position = Moon::Vector2[*args]
    self
  end

  def forward(d = 1.0)
    moveto(position + Moon::Vector2.new(0.0, move_distance * d))
  end

  def backward(d = 1.0)
    moveto(position + Moon::Vector2.new(0.0, -move_distance * d))
  end

  def left(d = 1.0)
    moveto(position + Moon::Vector2.new(-move_distance * d, 0.0))
  end

  def right(d = 1.0)
    moveto(position + Moon::Vector2.new(move_distance * d, 0.0))
  end
end
