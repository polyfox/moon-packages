class MapEditorGuiView < State::ViewBase
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
    super
    @screen_rect = Moon::Screen.rect.contract(16)

    @font = FontCache.font('uni0553', 16)
    @controlmap = DataCache.controlmap('map_editor')

    @hud = Moon::RenderContainer.new

    @help_panel       = ES::UI::MapEditorHelpPanel.new(@controlmap)
    @help_panel.position.set(@help_panel.to_rect.align('center', @screen_rect).xyz)

    @dashboard        = ES::UI::MapEditorDashboard.new
    @layer_view       = ES::UI::MapEditorLayerView.new
    @tile_info        = ES::UI::TileInfo.new
    @tile_panel       = ES::UI::TilePanel.new
    @tile_preview     = ES::UI::TilePreview.new

    @ui_posmon        = ES::UI::PositionMonitor.new
    @ui_camera_posmon = ES::UI::PositionMonitor.new

    @notifications    = ES::UI::Notifications.new

    texture = TextureCache.block 'passage_blocks.png'
    @passage_ss = Moon::Spritesheet.new texture, 32, 32

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

    add(@hud)
  end

  def start
    super
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

  def tileset=(tileset)
    @tileset = tileset
    @tile_preview.tileset = @tileset
    @tile_info.tileset = @tileset
    @tile_panel.tileset = @tileset
  end

  def update_content(delta)
    @hud.update(delta)
    @dashboard.update(delta)
    super
  end
end
