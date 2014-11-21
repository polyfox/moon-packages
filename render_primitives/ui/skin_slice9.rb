# :nodoc:
module Moon
  class SkinSlice9 < RenderContext
    # @return [Moon::Spritesheet]
    attr_accessor :windowskin

    ##
    #
    private def init_content
      super
      @windowskin = nil
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    private def render_content(x, y, z, options)
      if @windowskin
        cw, ch = @windowskin.cell_width, @windowskin.cell_height

        # render the windowskin (background)
        (width / cw).to_i.times do |w|
          (height / ch).to_i.times do |h|
            @windowskin.render x + w * cw, y + h * ch, z, 4
          end
        end
        # edges (top/bottom)
        (width / cw).to_i.times do |w|
          @windowskin.render x + w * cw, y, z, 1
          @windowskin.render x + w * cw, y + height - ch, z, 7
        end
        # edges (left/right)
        (height / ch).to_i.times do |h|
          @windowskin.render x, y + h * ch, z, 3
          @windowskin.render x + width - cw, y + h * ch, z, 5
        end
        # corners
        @windowskin.render x, y, z, 0
        @windowskin.render x + width - cw, y, z, 2
        @windowskin.render x, y + height - ch, z, 6
        @windowskin.render x + width - cw, y + height - ch, z, 8
      end
      super
    end
  end
end
