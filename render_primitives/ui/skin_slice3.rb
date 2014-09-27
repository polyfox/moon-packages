module Moon
  class SkinSlice3 < RenderContext
    attr_accessor :horz       # Boolean
    attr_accessor :windowskin # Spritesheet

    def init_content
      super
      @horz = true
      @windowskin = nil
    end

    def render_content(x, y, z, options)
      if @windowskin
        cw, ch = @windowskin.cell_width, @windowskin.cell_height

        if @horz
          @windowskin.render x, y, z, 0
          ((width/cw).to_i-2).times do |w|
            @windowskin.render x+(w+1)*cw, y, z, 1
          end
          @windowskin.render x+width-cw, y, z, 2
        else
          @windowskin.render x, y, z, 0
          ((height/ch).to_i-2).times do |h|
            @windowskin.render x, y+(h+1)*ch, z, 1
          end
          @windowskin.render x, y+height-ch, z, 2
        end
      end
      super
    end
  end
end
