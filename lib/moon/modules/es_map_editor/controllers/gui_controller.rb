class MapEditorGuiController < State::ControllerBase
  def center_on_map
    bounds = @model.map.bounds
    @model.cam_cursor.position.set(bounds.cx, bounds.cy, 0)
  end

  def camera_follow(obj)
    @model.camera.follow obj
    @view.ui_camera_posmon.obj = obj
  end

  def follow(obj)
    @view.ui_posmon.obj = obj
  end

  def refresh_follow
    if @model.keyboard_only_mode
      camera_follow @model.map_cursor
      follow @model.map_cursor
    else
      camera_follow @model.cam_cursor
      follow @model.map_cursor
    end
  end

  def toggle_grid
    @model.show_grid = !@model.show_grid
    @view.dashboard.toggle 7, @model.show_grid
  end

  def new_map
    @view.dashboard.enable 1
    @view.notifications.notify string: 'New Map'
    @model.map = create_map(name: 'New Map')
    @model.map.uri = "/maps/new/map-#{@model.map.id}"
    create_chunk(Moon::Rect.new(0, 0, 4, 4), name: "New Chunk #{@model.map.chunks.size}")
  end

  def on_new_map_release
    @view.dashboard.disable 1
    @view.notifications.clear
  end

  def save_map
    @view.dashboard.ok 4
    @model.map.to_map.save_file
    save_chunks
    @view.notifications.notify string: 'Saved'
  end

  def on_save_map_release
    @view.dashboard.disable 4
    @view.notifications.clear
  end

  def new_chunk
    @view.dashboard.enable 2
    @view.notifications.notify string: 'New Chunk'
    @model.selection_stage = 1
  end

  def new_chunk_stage_finish
    id = @model.map.chunks.size+1
    chunk = create_chunk @model.selection_rect,
                         name: "New Chunk #{id}"
    chunk.uri = "/chunks/new/chunk-#{chunk.id}"

    @model.selection_stage = 0
    @model.selection_rect.clear
    @view.dashboard.disable 2
    @view.notifications.clear
  end

  def new_chunk_stage
    case @model.selection_stage
    when 1
      @model.selection_stage += 1
    when 2
      new_chunk_stage_finish
    end
  end

  def new_chunk_revert
    case @mode.selection_stage
    when 1
      @model.selection_stage = 0
      @view.dashboard.disable 2
      @view.notifications.clear
    when 2
      @model.selection_rect.clear
      @model.selection_stage -= 1
    end
  end

  def create_chunk(bounds, data)
    chunk          = ES::EditorChunk.new(data)
    chunk.position = bounds.xyz
    chunk.data     = Moon::DataMatrix.new(bounds.w, bounds.h, 2, default: -1)
    chunk.passages = Moon::Table.new(bounds.w, bounds.h)
    chunk.flags    = Moon::DataMatrix.new(bounds.w, bounds.h, 2)
    chunk.tileset  = ES::Tileset.find_by(uri: '/tilesets/common')
    @model.map.chunks << chunk
    @view.refresh_tilemaps
    chunk
  end

  def create_map(data)
    map = ES::EditorMap.new(data)
    map
  end

  def save_chunks
    @model.map.chunks.each { |chunk| chunk.to_chunk.save_file }
  end

  def load_chunks
    @view.dashboard.ok 5
    @view.notifications.notify string: "Loading ... (NYI)"
  end

  def on_load_chunks_release
    @view.dashboard.disable 5
  end

  def rename_chunk(new_name)
    if chunk = chunk_at_position(@model.map_cursor.position.floor)
      chunk.name = new_name
    end
  end

  def move_chunk(x, y)
    if chunk = chunk_at_position(@model.map_cursor.position.xy.floor)
      pos = [x, y, 0]
      chunk.position += pos
      @model.map_cursor.position += pos
    end
  end

  def resize_chunk(x, y)
    if chunk = chunk_at_position(@model.map_cursor.position.xy.floor)
      chunk.resize(chunk.width + x, chunk.height + y)
    end
  end

  def toggle_keyboard_mode
    @model.keyboard_only_mode = !@model.keyboard_only_mode
    if @model.keyboard_only_mode
      @view.dashboard.ok(8)
      @view.notifications.notify string: "Keyboard Only Mode : ENABLED"
    else
      @view.dashboard.disable(8)
      @view.notifications.notify string: "Keyboard Only Mode : DISABLED"
    end
    refresh_follow
  end

  def set_layer(layer)
    @model.layer = layer
    @view.layer_view.index = @model.layer
    if @model.layer < 0
      @model.layer_opacity.map! { 1.0 }
    else
      @model.layer_opacity.map! { 0.3 }
      @model.layer_opacity[@model.layer] = 1.0
    end
    if layer < 0
      @view.notifications.notify string: "Layer editing deactivated"
    else
      @view.notifications.notify string: "Layer #{layer} set for editing"
    end
  end

  def place_tile(tile_id)
    tile_data = @view.tile_info.tile_data
    if chunk = tile_data.chunk
      dx, dy, _ = *tile_data.chunk_data_position
      chunk.data[dx, dy, @model.layer] = tile_id
    end
  end

  def rect_selection?
    @model.selection_stage > 0
  end

  def place_current_tile
    return if rect_selection?
    place_tile @view.tile_panel.tile_id
  end

  def copy_tile
    return if rect_selection?
    tile_ids = @view.tile_info.tile_data.tile_ids
    tile_id = tile_ids.reject { |n| n == -1 }.last || -1
    @view.tile_panel.tile_id = tile_id
  end

  def erase_tile
    return if rect_selection?
    place_tile(-1)
  end

  def select_tile(pos)
    @view.tile_panel.select_tile(pos)
  end

  def move_cursor(xv, yv)
    @model.map_cursor.position += [xv, yv, 0]
  end

  def set_camera_velocity(x, y)
    @model.cam_cursor.velocity.x = x * @model.camera_move_speed.x if x
    @model.cam_cursor.velocity.y = y * @model.camera_move_speed.y if y
  end

  def animate_map_zoom(dest)
    zoom = @model.zoom
    @model.zoom = dest
    puts "Zoom has been disabled"
  end

  def zoom_reset
    animate_map_zoom(1.0)
  end

  def zoom_out
    animate_map_zoom(@model.zoom/2.0)
  end

  def zoom_in
    animate_map_zoom(@model.zoom*2.0)
  end

  def autosave
    save_map
    @view.notifications.notify string: "Autosaved!"
  end

  def show_help
    @view.dashboard.enable 0
    @view.notifications.notify string: "Help"
    @view.help_panel.show
  end

  def hide_help
    @view.dashboard.disable 0
    @view.notifications.clear
    @view.help_panel.hide
  end

  def show_tile_info
    @view.tile_info.show
  end

  def hide_tile_info
    @view.tile_info.hide
  end

  def show_tile_panel
    @view.tile_panel.show
  end

  def hide_tile_panel
    @view.tile_panel.hide
  end

  def show_tile_preview
    @view.tile_preview.show
  end

  def hide_tile_preview
    @view.tile_preview.hide
  end

  def show_chunk_labels
    @view.dashboard.enable 9
    @model.flag_show_chunk_labels = true
    @view.notifications.notify string: "Showing Chunk Labels"
  end

  def hide_chunk_labels
    @view.dashboard.disable 9
    @model.flag_show_chunk_labels = false
    @view.notifications.clear
  end

  def edit_tile_palette
    State.push(States::TilePaletteEditor)
  end

  def chunk_at_position(position)
    chunk = @model.map.chunks.find do |c|
      c.bounds.contains?(position)
    end
  end

  def get_tile_data(position)
    position = position.floor
    chunk = chunk_at_position(position)
    tile_data = ES::TileData.new
    if chunk
      tile_data.chunk = chunk
      tile_data.data_position = position.xyz
      tile_data.chunk_data_position = position.xyz - chunk.position.xyz
      x, y, _ = *tile_data.chunk_data_position
      tile_data.tile_ids = chunk.data.sampler.pillar(x, y).to_a
      tile_data.passage = chunk.passages[*tile_data.chunk_data_position.xy]
    end
    tile_data
  end

  def update_cursor_position(delta)
    unless @model.keyboard_only_mode
      @model.map_cursor.position = @model.camera.screen_to_world(Moon::Input::Mouse.position.xyz).floor
    end
    @view.tile_info.tile_data = get_tile_data(@model.map_cursor.position.xy)
  end

  def update(delta)
    update_cursor_position(delta)

    @view.tile_preview.tile_id = @view.tile_panel.tile_id

    if @model.selection_stage == 1
      @model.selection_rect.xyz = @model.map_cursor.position
    elsif @model.selection_stage == 2
      @model.selection_rect.whd = @model.map_cursor.position -
                                  @model.selection_rect.xyz
    end
    super
  end
end
