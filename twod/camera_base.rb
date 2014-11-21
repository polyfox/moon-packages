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
  # @!attribute viewport
  #   @return [Moon::Rect]
  field :viewport, type: Moon::Rect,    default: (proc do
    Moon::Rect.new(-Moon::Screen.width / 2, -Moon::Screen.height / 2,
                    Moon::Screen.width / 2,  Moon::Screen.height / 2)
  end)

  # @abstract Subclass and overwrite using .field with a Moon::Vector class
  abstract_attr_accessor :position
  # @abstract Subclass and overwrite using .field with a Moon::Vector class
  abstract_attr_accessor :tilesize

  ##
  # Camera should follow this object every update
  #
  # @param [#position] obj
  def follow(obj)
    @obj = obj
    puts "[Camera:follow] #{obj}"
  end

  # @abstract
  abstract :view

  ##
  # Frame update
  #
  # @param [Float] delta
  def update(delta)
    update_transitions delta
    if @obj
      @position += (@obj.position * @tilesize - @position) * @speed * delta
    end
    @ticks += 1
  end

  ##
  # @param [Moon::Vector2, Moon::Vector3] screen_pos
  # @return [Moon::Vector2, Moon::Vector3]
  def screen_to_world(screen_pos)
    (view.floor + screen_pos) / @tilesize
  end

  ##
  # @param [Moon::Vector2, Moon::Vector3] screen_pos
  # @return [Moon::Vector2, Moon::Vector3]
  def screen_to_world_reduce(screen_pos)
    screen_to_world(screen_pos).floor * @tilesize - view.floor
  end

  ##
  # @param [Moon::Vector2, Moon::Vector3] world_pos
  # @return [Moon::Vector2, Moon::Vector3]
  def world_to_screen(world_pos)
    map_pos * @tilesize - view.floor
  end
end
