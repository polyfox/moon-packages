class CameraBase < Moon::DataModel::Metal
  field :speed,    type: Integer,       default: 4
  field :ticks,    type: Integer,       default: 0
  field :obj,      type: Object,        allow_nil: true, default: nil
  field :viewport, type: Moon::Rect,    default: (proc do
    Moon::Rect.new(-Moon::Screen.width/2, -Moon::Screen.height/2,
                    Moon::Screen.width/2,  Moon::Screen.height/2)
  end)

  def post_init
    super
  end

  def follow(obj)
    @obj = obj
    puts "[Camera:follow] #{obj}"
  end

  def view
    @position + @viewport.xy
  end

  def update(delta)
    if @obj
      @position += (@obj.position * @tilesize - @position) * @speed * delta
    end
    @ticks += 1
  end

  def screen_to_world(screen_pos)
    (screen_pos + view.floor) / @tilesize
  end

  def screen_to_world_reduce(screen_pos)
    screen_to_world(screen_pos).floor * @tilesize - view.floor
  end

  def world_to_screen(world_pos)
    map_pos * @tilesize - view.floor
  end
end
