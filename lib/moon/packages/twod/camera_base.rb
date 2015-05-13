##
# Generic Point Camera
class CameraBase < Moon::DataModel::Metal
  include Moon::Transitionable

  # @!attribute speed
  #   @return [Integer]
  field :speed,    type: Integer,       default: 4
  # @!attribute ticks
  #   @return [Integer]
  field :ticks,    type: Integer,       default: 0
  # @!attribute obj
  #   @return [Object]
  field :obj,      type: Object,        allow_nil: true, default: nil
  # @!attribute view
  #   @return [Moon::Rect]
  field :view,     type: Moon::Rect

  # @abstract Subclass and overwrite using .field with a Moon::Vector* class
  abstract_attr_accessor :position
  # @abstract Subclass and overwrite using .field with a Moon::Vector* class
  abstract_attr_accessor :tilesize

  abstract :view_offset

  ##
  # Camera should follow this object every update
  #
  # @param [#position] obj
  def follow(obj)
    @obj = obj
    puts "[Camera:follow] #{obj}"
  end

  # @return [Vector]
  def velocity(delta)
    if @obj
      (@obj.position * @tilesize - @position) * @speed * delta
    else
      0
    end
  end

  # Frame update
  #
  # @param [Float] delta
  def update(delta)
    update_transitions delta
    @position += velocity delta
    @ticks += 1
  end

  ##
  # @param [Moon::Vector2, Moon::Vector3] screen_pos
  # @return [Moon::Vector2, Moon::Vector3]
  def screen_to_world(screen_pos)
    (view_offset.floor + screen_pos) / @tilesize
  end

  ##
  # @param [Moon::Vector2, Moon::Vector3] screen_pos
  # @return [Moon::Vector2, Moon::Vector3]
  def screen_to_world_reduce(screen_pos)
    screen_to_world(screen_pos).floor * @tilesize - view_offset.floor
  end

  ##
  # @param [Moon::Vector2, Moon::Vector3] world_pos
  # @return [Moon::Vector2, Moon::Vector3]
  def world_to_screen(world_pos)
    map_pos * @tilesize - view_offset.floor
  end
end
