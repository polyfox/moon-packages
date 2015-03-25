##
# Generic Map Cursor renderer
class MapCursorRenderer < Moon::RenderContext
  def init
    super
    @texture = TextureCache.ui('map_editor_cursor.png')
    @sprite = Moon::Sprite.new(@texture)
  end

  def render_content(x, y, z, options)
    @sprite.render x, y, z
    super
  end
end

##
# Generic Renderer object for display a L shaped border
class BorderRenderer < Moon::RenderContext
  attr_accessor :border_rect

  def init
    super
    @texture = TextureCache.ui('chunk_outline_3x3.png')
    @chunk_borders = Moon::Spritesheet.new(@texture, 32, 32)
    @border_rect = Moon::Rect.new(0, 0, 0, 0)
  end

  def render_content(x, y, z, options)
    unless @border_rect.empty?
      w = @border_rect.width - 32
      h = @border_rect.height - 32
      @chunk_borders.render(x,     y,     z, 0)
      @chunk_borders.render(x + w, y,     z, 2)
      @chunk_borders.render(x,     y + h, z, 6)
      @chunk_borders.render(x + w, y + h, z, 8)
    end
    super
  end
end

##
# Specialized renderer for rendering EditorChunks
class ChunkRenderer < Moon::RenderContext
  attr_reader :chunk

  def init
    super
    @tilemap = Moon::Tilemap.new
    @size = Moon::Vector3.new(1, 1, 1)
  end

  def width
    @tilemap.width
  end

  def height
    @tilemap.height
  end

  def layer_opacity
    @tilemap.layer_opacity
  end

  def layer_opacity=(layer_opacity)
    @tilemap.layer_opacity = layer_opacity
  end

  def refresh
    tileset = @chunk.tileset
    @texture = TextureCache.tileset(tileset.filename)
    @tilemap.tileset = Moon::Spritesheet.new(@texture, tileset.cell_width,
                                                       tileset.cell_height)
    @tilemap.data = @chunk.data
    @tilemap.flags = @chunk.flags
    @size = Moon::Vector3.new(tileset.cell_width, tileset.cell_height, 1)
  end

  def chunk=(chunk)
    @chunk = chunk
    refresh
  end

  def update(delta)
    self.position = @chunk.position * @size
    super
  end

  def render_content(x, y, z, options)
    @tilemap.render(x, y, z, options)
    super
  end
end

##
# Specialized renderer for rendering EditorChunks with grid and border
# additions
class EditorChunkRenderer < ChunkRenderer
  attr_accessor :show_border
  attr_accessor :show_label
  attr_accessor :show_underlay
  attr_accessor :show_overlay

  def init
    super
    @show_border = false
    @show_label = false
    @show_underlay = false
    @show_overlay = false

    @underlay_texture = TextureCache.ui('grid_32x32_ff777777.png')
    @overlay_texture = TextureCache.ui('grid_32x32_ffffffff.png')
    @grid_underlay = Moon::Sprite.new(@underlay_texture)
    @grid_overlay  = Moon::Sprite.new(@overlay_texture)

    @border_renderer = BorderRenderer.new

    @label_color = Moon::Vector4.new(1, 1, 1, 1)
    @label_font = FontCache.font('uni0553', 16)
  end

  def render_label(x, y, z, options)
    oy = @label_font.size + 8
    @label_font.render(x, y - oy, z, @chunk.name, @label_color, outline: 0)
  end

  def render_content(x, y, z, options)
    return unless @chunk

    bound_rect = Moon::Rect.new(0, 0, *(@chunk.bounds.wh * 32))

    if options.fetch(:show_underlay, @show_underlay)
      @grid_underlay.clip_rect = bound_rect
      @grid_underlay.render(x, y, z)
    end

    super

    if options.fetch(:show_border, @show_border)
      @border_renderer.border_rect = bound_rect
      @border_renderer.render(x, y, z, options)
    end

    if options.fetch(:show_overlay, @show_overlay)
      @grid_overlay.clip_rect = bound_rect
      @grid_overlay.render(x, y, z)
    end

    render_label(x, y, z, options) if options.fetch(:show_label, @show_label)
  end
end

##
# Specialized renderer for rendering EditorMaps
class MapRenderer < Moon::RenderArray
  # @return [Camera3]
  attr_accessor :camera
  # @return [ES::EditorMap]
  attr_accessor :dm_map
  # @return [Array<Float>]
  attr_accessor :layer_opacity

  def init
    super
    @layer_opacity = [1.0, 1.0]
  end

  def layer_opacity=(layer_opacity)
    @layer_opacity = layer_opacity
    @elements.each do |e|
      e.layer_opacity = @layer_opacity
    end
  end

  def chunk_renderer_class
    ChunkRenderer
  end

  def dm_map=(dm_map)
    clear
    @dm_map = dm_map
    @dm_map.chunks.each do |chunk|
      renderer = chunk_renderer_class.new
      renderer.chunk = chunk
      renderer.layer_opacity = @layer_opacity
      add(renderer)
    end
    # clear size, so it can refresh
    self.width = nil
    self.height = nil
  end

  def apply_position_modifier(vec3 = 0)
    pos = super(vec3)
    pos -= @camera.view if @camera
    pos
  end
end

##
# Extended renderer for rendering EditorMaps with support for borders, labels,
# overlays and underlays
class EditorMapRenderer < MapRenderer
  attr_accessor :show_borders
  attr_accessor :show_labels
  attr_accessor :show_underlay
  attr_accessor :show_overlay

  def init
    super
    @show_borders = false
    @show_labels = false
    @show_underlay = false
    @show_overlay = false
  end

  def chunk_renderer_class
    EditorChunkRenderer
  end

  def render_show_options
    options = {}
    options[:show_border] = @show_borders unless @show_borders.nil?
    options[:show_label] = @show_labels unless @show_labels.nil?
    options[:show_underlay] = @show_underlay unless @show_underlay.nil?
    options[:show_overlay] = @show_overlay unless @show_overlay.nil?
    options
  end

  def render_content(x, y, z, options)
    super x, y, z, options.merge(render_show_options)
  end
end
