##
# Generic 3D Cursor
class Cursor3 < Moon::DataModel::Metal
  include Movable3

  # @!attribute position
  #   @return [Moon::Vector2]
  field :position, type: Moon::Vector3, default: proc{ |t| t.new }
end
