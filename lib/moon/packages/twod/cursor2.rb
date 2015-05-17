require 'std/mixins/eventable'

# Generic 2D Cursor
class Cursor2 < Moon::DataModel::Metal
  include Moon::Eventable
  include Moon::Activatable
  include Movable2

  # @!attribute active
  #   @return [Boolean]
  field :active, type: Boolean, default: true

  # @!attribute position
  #   @return [Moon::Vector2]
  field :position, type: Moon::Vector2, default: proc{ |t| t.model.new }

  def pre_initialize
    super
    initialize_eventable
  end

  def movable?
    active?
  end
end
