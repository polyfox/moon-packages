require 'render_primitives/render_context'

module Moon
  class SkinSlice9 < RenderContext
    # @return [Moon::Spritesheet]
    attr_accessor :windowskin

    ##
    #
    protected def initialize_content
      super
      @windowskin = nil
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    protected def render_content(x, y, z)
      return unless @windowskin
      cw, ch = @windowskin.w, @windowskin.h

      # render the windowskin (background)
      (w / cw).to_i.times do |w|
        (h / ch).to_i.times do |h|
          @windowskin.render x + w * cw, y + h * ch, z, 4
        end
      end
      # edges (top/bottom)
      (w / cw).to_i.times do |w|
        @windowskin.render x + w * cw, y, z, 1
        @windowskin.render x + w * cw, y + h - ch, z, 7
      end
      # edges (left/right)
      (h / ch).to_i.times do |h|
        @windowskin.render x, y + h * ch, z, 3
        @windowskin.render x + w - cw, y + h * ch, z, 5
      end
      # corners
      @windowskin.render x, y, z, 0
      @windowskin.render x + w - cw, y, z, 2
      @windowskin.render x, y + h - ch, z, 6
      @windowskin.render x + w - cw, y + h - ch, z, 8
    end
  end
end
