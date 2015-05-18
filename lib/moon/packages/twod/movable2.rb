require 'std/mixins/eventable'
require 'twod/moved_event'

# required methods, #position, #position=
module Movable2
  include Moon::Eventable

  def move_distance
    1
  end

  def movable?
    true
  end

  # @param [Moon::Vector2] position
  # @return [Moon::Vector2]
  def adjust_position(position)
    position
  end

  # @overload moveto(position)
  #   @param [Moon::Vector2] position
  # @overload moveto(x, y)
  #   @param [Numeric] x
  #   @param [Numeric] y
  # @return [self]
  def moveto(*args)
    return self unless movable?
    old_pos = position
    self.position = adjust_position(Moon::Vector2[*args])
    trigger { Moon::MovedEvent.new self, old_pos, position }
    self
  end

  def move(*args)
    moveto(position + Moon::Vector2[*args] * move_distance)
  end

  def forward(d = 1.0)
    move(0, d)
  end

  def backward(d = 1.0)
    move(0, -d)
  end

  def left(d = 1.0)
    move(-d, 0)
  end

  def right(d = 1.0)
    move(d, 0)
  end
end
