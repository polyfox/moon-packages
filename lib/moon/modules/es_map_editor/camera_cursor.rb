class CameraCursor < Cursor3
  field :velocity, type: Moon::Vector3, default: proc{|t|t.new}

  def update(delta)
    @position += @velocity * delta
  end
end
