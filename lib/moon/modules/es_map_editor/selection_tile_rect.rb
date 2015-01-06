module ES
  module UI
    class SelectionTileRect < Moon::RenderContext
      attr_accessor :tile_rect
      attr_accessor :color
      attr_accessor :spritesheet
      attr_reader :cell_size

      def init
        super
        @active = false
        @tile_rect = Moon::Rect.new(0, 0, 0, 0)
        @spritesheet = nil
        @cell_size = Moon::Vector3.new(0, 0, 0)
        @color = Moon::Vector4.new(1.0, 1.0, 1.0, 1.0)
      end

      def refresh_spritesheet
        if @spritesheet
          @cell_size = Moon::Vector3.new(@spritesheet.cell_width,
                                         @spritesheet.cell_height,
                                         1)
        else
          @cell_size = Moon::Vector3.new(1, 1, 1)
        end
      end

      def spritesheet=(spritesheet)
        @spritesheet = spritesheet
        refresh_spritesheet
      end

      def width
        return 0 unless @spritesheet
        @spritesheet.cell_width * @tile_rect.w
      end

      def height
        return 0 unless @spritesheet
        @spritesheet.cell_height * @tile_rect.h
      end

      def render_content(x, y, z, options)
        if @spritesheet
          cw, ch = @cell_size.x, @cell_size.y
          px, py, pz = *(@tile_rect.xyz * @cell_size + [x, y, z])
          render_options = { color: @color }.merge(options)
          @tile_rect.h.times do |i|
            row = py + i * ch
            @tile_rect.w.times do |j|
              @spritesheet.render px + j * cw,
                                  row,
                                  pz,
                                  6, render_options
            end
          end
        end
        super
      end
    end
  end
end
