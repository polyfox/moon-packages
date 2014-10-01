class MapCursorRenderer < Moon::RenderContext
  def init
    super
    @sprite = Moon::Sprite.new("resources/ui/map_editor_cursor.png")
  end

  def render_content(x, y, z, options)
    @sprite.render x, y, z
    super
  end
end

class ChunkRenderer < Moon::RenderContext
  attr_reader :chunk

  def init
    super
    @tilemap = Moon::Tilemap.new
    @size = Moon::Vector3.new(1, 1, 1)
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
    @tilemap.tileset = Moon::Spritesheet.new(@texture, tileset.cell_width, tileset.cell_height)
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

class EditorChunkRenderer < ChunkRenderer
  def init
    super
    @grid_underlay = Moon::Sprite.new("resources/ui/grid_32x32_ff777777.png")
    @grid_overlay  = Moon::Sprite.new("resources/ui/grid_32x32_ffffffff.png")
    @chunk_borders = Moon::Spritesheet.new("resources/ui/chunk_outline_3x3.png", 32, 32)

    @label_color = Moon::Vector4.new(1, 1, 1, 1)
    @label_font = FontCache.font "uni0553", 16
  end

  def render_content(x, y, z, options)
    return unless @chunk

    if options[:show_underlay]
      @grid_underlay.clip_rect = Moon::Rect.new(0, 0, *(@chunk.bounds.wh*32))
      @grid_underlay.render(x, y, z-0.5)
    end

    super

    if options[:show_borders]
      x2 = @grid_underlay.clip_rect.width-32
      y2 = @grid_underlay.clip_rect.height-32
      @chunk_borders.render(x, y, z, 0)
      @chunk_borders.render(x+x2, y, z, 2)
      @chunk_borders.render(x, y+y2, z, 6)
      @chunk_borders.render(x+x2, y+y2, z, 8)
    end

    if options[:show_overlay]
      @grid_overlay.clip_rect = Rect.new(0, 0, *@grid_underlay.clip_rect.wh)
      @grid_overlay.render(x, y, z)
    end

    if options[:show_labels]
      oy = @label_font.size+8
      @label_font.render x, y-oy, z, @chunk.name, @label_color, outline: 0
    end
  end
end

class MapRenderer < Moon::RenderArray
  attr_accessor :dm_map
  attr_reader :layer_opacity

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
  end
end

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

  def render_content(x, y, z, options)
    super x, y, z, options.merge(
      show_borders: @show_borders,
      show_labels: @show_labels,
      show_underlay: @show_underlay,
      show_overlay: @show_overlay
    )
  end
end

class MapEditorView < State::ViewBase
  attr_accessor :notifications
  attr_reader :screen_rect

  attr_reader :tileset

  attr_reader :dashboard
  attr_reader :hud
  attr_reader :layer_view
  attr_reader :help_panel
  attr_reader :tile_info
  attr_reader :tile_panel
  attr_reader :tile_preview
  attr_reader :tileselection_rect
  attr_reader :ui_camera_posmon
  attr_reader :ui_posmon

  def init_view
    @screen_rect = Moon::Screen.rect.contract(16)

    @palette = DataCache.palette
    @font = FontCache.font "uni0553", 16
    @controlmap = DataCache.controlmap("map_editor")

    @hud = Moon::RenderContainer.new

    @help_panel       = ES::UI::MapEditorHelpPanel.new(@controlmap)
    @help_panel.position.set(@help_panel.to_rect.align("center", @screen_rect).xyz)

    @dashboard        = ES::UI::MapEditorDashboard.new
    @layer_view       = ES::UI::MapEditorLayerView.new
    @tile_info        = ES::UI::TileInfo.new
    @tile_panel       = ES::UI::TilePanel.new
    @tile_preview     = ES::UI::TilePreview.new

    @ui_posmon        = ES::UI::PositionMonitor.new
    @ui_camera_posmon = ES::UI::PositionMonitor.new

    @notifications    = ES::UI::Notifications.new

    @tileselection_rect = ES::UI::SelectionTileRect.new

    @map_renderer = EditorMapRenderer.new

    @map_cursor = MapCursorRenderer.new
    texture  = TextureCache.block "e032x032.png"
    @cursor_ss  = Moon::Spritesheet.new texture, 32, 32
    texture = TextureCache.block "passage_blocks.png"
    @passage_ss = Moon::Spritesheet.new texture, 32, 32

    color = @palette["system/selection"]
    @tileselection_rect.spritesheet = @cursor_ss
    @tileselection_rect.color = color

    @notifications.font = @font

    refresh_position

    @dashboard.show
    @tile_panel.hide
    @help_panel.hide

    @hud.add @dashboard
    @hud.add @layer_view
    @hud.add @tile_info
    @hud.add @tile_panel
    @hud.add @tile_preview
    @hud.add @ui_camera_posmon
    @hud.add @ui_posmon
    @hud.add @notifications
    @hud.add @help_panel

    add(@map_renderer)
    add(@map_cursor)
    add(@hud)
    create_passage_layer
  end

  def start
    refresh_tilemaps
  end

  def refresh_position
    @dashboard.position.set @screen_rect.x, @screen_rect.y, 0
    @tile_info.position.set @screen_rect.x, @dashboard.y2 + 16, 0
    @tile_preview.position.set @screen_rect.x2 - @tile_preview.width, @dashboard.y2, 0
    @tile_panel.position.set @screen_rect.x, @screen_rect.y2 - 32 * @tile_panel.visible_rows - 16, 0
    @layer_view.position.set @tile_preview.x, @tile_preview.y2, 0
    @notifications.position.set @font.size, @screen_rect.y2 - @font.size*2, 0
    @ui_posmon.position.set @screen_rect.x2 - @ui_posmon.width - 96, @screen_rect.y, 0
    @ui_camera_posmon.position.set (@screen_rect.width - @ui_camera_posmon.width) / 2,
                                    @screen_rect.y2 - @font.size,
                                    0
  end

  def refresh_tilemaps
    @map_renderer.dm_map = @model.map
    @map_renderer.layer_opacity = @model.layer_opacity
  end

  def tileset=(tileset)
    @tileset = tileset
    @tile_preview.tileset = @tileset
    @tile_info.tileset = @tileset
    @tile_panel.tileset = @tileset
  end

  def create_passage_layer
    @passage_tilemap = Moon::Tilemap.new do |tilemap|
      tilemap.position.set 0, 0, 0
      tilemap.tileset = @passage_ss
      tilemap.data = @passage_data # special case passage data
    end
  end

  def render_edit_mode
    campos = @model.camera.view.floor
    if @model.selection_stage > 0
      @tileselection_rect.render(*(-campos))
    end
  end

  def render_content(x, y, z, options)
    render_edit_mode
    super
  end

  def update_content(delta)
    show_labels = @model.flag_show_chunk_labels
    campos = @model.camera.view.floor
    @hud.update(delta)
    @dashboard.update(delta)
    @map_cursor.position = @model.map_cursor.position * 32 - campos
    @map_renderer.show_borders = show_labels
    @map_renderer.show_labels = show_labels
    @map_renderer.show_underlay = @model.show_grid
    @map_renderer.position = -campos
    super
  end
end
