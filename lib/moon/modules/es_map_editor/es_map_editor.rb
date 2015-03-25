module States
  ##
  # Built-in Map Editor for editing ES-Moon style maps and chunks
  class EsMapEditor < States::Base
    attr_reader :model
    attr_reader :controller
    attr_reader :view

    def init
      super
      create_mvc
      create_input_delegate
      create_world
      create_map
      create_autosave_interval
    end

    def start
      super
      #@map_controller.refresh_follow
      @gui_controller.refresh_follow
      @map_controller.start
      @gui_controller.start
    end

    private def create_model
      @model = MapEditorModel.new
      @model.tile_palette.tileset = ES::Tileset.find_by(uri: '/tilesets/common')
    end

    private def create_view
      @map_view = MapEditorMapView.new(model: @model)
      @gui_view = MapEditorGuiView.new(model: @model)
      tileset = @model.tile_palette.tileset
      texture = TextureCache.tileset(tileset.filename)
      @gui_view.tileset = Moon::Spritesheet.new(texture, tileset.cell_width,
                                                         tileset.cell_height)
      @renderer.add @map_view
      @gui.add @gui_view
    end

    private def create_controller
      @map_controller = MapEditorMapController.new @model, @map_view
      @gui_controller = MapEditorGuiController.new @model, @gui_view
      @updatables.push @map_controller
      @updatables.push @gui_controller
      @gui_controller.set_layer(-1)
    end

    private def create_mvc
      create_model
      create_view
      create_controller
    end

    private def create_input_delegate
      @inp = MapEditorInputDelegate.new @gui_controller
      @inp.register input
      input.on(:any) do |e|
        @gui_view.trigger e
        @map_view.trigger e
      end
    end

    private def create_world
      @world = Moon::World.new
      @updatables.unshift @world
    end

    private def create_map
      map = ES::Map.find_by(uri: '/maps/school/f1')
      @model.map = map.to_editor_map
      @model.map.chunks = map.chunks.map do |chunk_head|
        chunk = ES::Chunk.find_by(uri: chunk_head.uri)
        editor_chunk = chunk.to_editor_chunk
        editor_chunk.position = chunk_head.position
        editor_chunk.tileset = ES::Tileset.find_by(uri: chunk.tileset.uri)
        editor_chunk
      end
    end

    private def create_autosave_interval
      @autosave_interval = scheduler.every('3m') do
        @controller.autosave
      end.tag('autosave')
    end

    private def update_world(delta)
      @world.update(delta)
    end

    def update(delta)
      update_world(delta)
      super delta
    end
  end
end
