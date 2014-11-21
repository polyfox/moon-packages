class CameraBase < Moon::DataModel::Metal
  include Moon::Transitionable

  field :speed,    type: Integer,       default: 4
  field :ticks,    type: Integer,       default: 0
  field :obj,      type: Object,        allow_nil: true, default: nil
  field :viewport, type: Moon::Rect,    default: (proc do
    Moon::Rect.new(-Moon::Screen.width / 2, -Moon::Screen.height / 2,
                    Moon::Screen.width / 2,  Moon::Screen.height / 2)
  end)

  abstract_attr_accessor :position
  abstract_attr_accessor :tilesize

  def follow(obj)
    @obj = obj
    puts "[Camera:follow] #{obj}"
  end

  abstract :view

  def update(delta)
    update_transitions delta
    if @obj
      @position += (@obj.position * @tilesize - @position) * @speed * delta
    end
    @ticks += 1
  end

  def screen_to_world(screen_pos)
    (view.floor + screen_pos) / @tilesize
  end

  def screen_to_world_reduce(screen_pos)
    screen_to_world(screen_pos).floor * @tilesize - view.floor
  end

  def world_to_screen(world_pos)
    map_pos * @tilesize - view.floor
  end
end
