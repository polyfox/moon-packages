##
# 3D Point Camera
class Camera3 < CameraBase
  include Movable3

  # @!attribute position
  #   @return [Moon::Vector3]
  field :position, type: Moon::Vector3, default: proc{ |t| t.model.new }
  # @!attribute tilesize
  #   @return [Moon::Vector3]
  field :tilesize, type: Moon::Vector3, default: proc{ |t| t.model.new(32, 32, 32) }

  ##
  # Returns the point offset in a 3D space
  #
  # @return [Moon::Vector3]
  def view_offset
    @position + Moon::Vector3[@view.position, 0]
  end
end
