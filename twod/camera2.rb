class Camera2 < CameraBase
  include Movable2

  field :position, type: Moon::Vector2, default: proc{ |t| t.new }
  field :tilesize, type: Moon::Vector2, default: proc{ |t| t.new(32, 32) }
  def view
    @position + @viewport.xy
  end
end
