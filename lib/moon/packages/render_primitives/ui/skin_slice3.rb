# :nodoc:
module Moon
  class SkinSlice3 < RenderContext
    # @return [Boolean]
    attr_accessor :horz
    # @return [Moon::Spritesheet]
    attr_accessor :windowskin

    ##
    #
    private def init_content
      super
      @horz = true
      @windowskin = nil
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    private def render_content(x, y, z, options)
      if @windowskin
        cw, ch = @windowskin.cell_w, @windowskin.cell_h

        if @horz
          @windowskin.render x, y, z, 0
          ((w / cw).to_i - 2).times do |w|
            @windowskin.render x + (w + 1) * cw, y, z, 1
          end
          @windowskin.render x + w - cw, y, z, 2
        else
          @windowskin.render x, y, z, 0
          ((h / ch).to_i - 2).times do |h|
            @windowskin.render x, y + (h + 1) * ch, z, 1
          end
          @windowskin.render x, y + h - ch, z, 2
        end
      end
      super
    end
  end
end
