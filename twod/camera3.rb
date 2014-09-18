class Camera3 < Moon::DataModel::Metal
  field :position, type: Moon::Vector3, default: proc{|t|t.new}
  field :tilesize, type: Moon::Vector3, default: proc{|t|t.new(32, 32, 32)}
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
    @position + @viewport.xyz
  end

  def update(delta)
    if @obj
      @position += (@obj.position * @tilesize - @position) * @speed * delta
    end
    @ticks += 1
  end
end
