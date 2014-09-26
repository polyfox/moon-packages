class CameraCursor < Moon::DataModel::Metal
  field :position, type: Moon::Vector3, default: proc{|t|t.new}
  field :velocity, type: Moon::Vector3, default: proc{|t|t.new}

  def update(delta)
    @position += @velocity * delta
  end
end
