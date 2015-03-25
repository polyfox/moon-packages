class MapEditorMapView < State::ViewBase
  def start
    super
    refresh_tilemaps
  end

  def init_view
    super
    @tileselection_rect = ES::UI::SelectionTileRect.new
    @map_renderer = EditorMapRenderer.new
    @map_cursor = MapCursorRenderer.new
    texture  = TextureCache.block 'e032x032.png'
    @cursor_ss  = Moon::Spritesheet.new texture, 32, 32
    color = DataCache.palette['system/selection']
    @tileselection_rect.spritesheet = @cursor_ss
    @tileselection_rect.color = color

    create_passage_layer

    add(@map_cursor)
  end

  private def create_passage_layer
    t = @passage_tilemap = Moon::Tilemap.new
    t.position.set 0, 0, 0
    t.tileset = @passage_ss
    t.data = @passage_data # special case passage data
  end

  def refresh_tilemaps
    @map_renderer.dm_map = @model.map
    @map_renderer.layer_opacity = @model.layer_opacity
  end

  def update_content(delta)
    show_labels = @model.flag_show_chunk_labels
    campos = @model.camera.view.floor
    @map_cursor.position = @model.map_cursor.position * 32 - campos
    @map_renderer.show_borders = show_labels
    @map_renderer.show_labels = show_labels
    @map_renderer.show_underlay = @model.show_grid
    @map_renderer.position = -campos
    super
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
end
