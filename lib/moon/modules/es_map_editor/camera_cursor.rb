class CameraCursor < Cursor2
  field :velocity, type: Moon::Vector2, default: proc{ |t| t.new }

  def update(delta)
    @position += @velocity * delta
  end
end
