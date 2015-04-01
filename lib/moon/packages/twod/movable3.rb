module Movable3
  def move_distance
    1
  end

  def moveto(*args)
    self.position = Moon::Vector3[*args]
    self
  end

  def up(d = 1.0)
    moveto(position + Moon::Vector3.new(0.0, 0.0, move_distance * d))
  end

  def down(d = 1.0)
    moveto(position + Moon::Vector3.new(0.0, 0.0, -move_distance * d))
  end

  def forward(d = 1.0)
    moveto(position + Moon::Vector3.new(0.0, move_distance * d, 0.0))
  end

  def backward(d = 1.0)
    moveto(position + Moon::Vector3.new(0.0, -move_distance * d, 0.0))
  end

  def left(d = 1.0)
    moveto(position + Moon::Vector3.new(-move_distance * d, 0.0, 0.0))
  end

  def right(d = 1.0)
    moveto(position + Moon::Vector3.new(move_distance * d, 0.0, 0.0))
  end
end
