##
# 2D Point Camera
class Camera2 < CameraBase
  include Movable2

  # @!attribute position
  #   @return [Moon::Vector2]
  field :position, type: Moon::Vector2, default: proc{ |t| t.model.new }
  # @!attribute tilesize
  #   @return [Moon::Vector2]
  field :tilesize, type: Moon::Vector2, default: proc{ |t| t.model.new(32, 32) }

  ##
  # Returns the point offset in a 2D space
  #
  # @return [Moon::Vector2]
  def view_offset
    @position + @view.position
  end
end
