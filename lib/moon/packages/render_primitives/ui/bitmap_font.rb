require 'render_primitives/render_context'

module Moon
  # Renderer object, for rendering bitmap font Spritesheets
  class BitmapFont < RenderContext
    # @return [String]
    attr_reader :string
    # @return [Boolean]
    attr_accessor :bold
    # @return [Moon::Vector4]
    attr_accessor :color

    # @param [Moon::Spritesheet] spritesheet
    # @param [String] string initial ASCII string value
    # @param [Hash<Symbol, Object>] options
    def initialize(spritesheet, string = '', options = {})
      super options
      @color = Vector4.new(1.0, 1.0, 1.0, 1.0)
      @spritesheet = spritesheet
      self.string = string
    end

    # @param [String] string
    def string=(string)
      @string = (string && string.to_s) || nil
      refresh_size
    end

    # Recalculate size
    private def refresh_size
      @cached_w = @string.size * @spritesheet.w
      @cached_h = (@string.count("\n") + 1) * @spritesheet.h

      self.w = @cached_w
      self.h = @cached_h
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    protected def render_content(x, y, z)
      return unless @string
      offset = @bold ? 256 : 0
      row = 0
      col = 0

      row_size = @cell_size[1]
      row_y = y + row * row_size
      @string.each_byte do |byte|
        if byte.chr == 10 # \n
          col = 0
          row += 1
          row_y = y + row * row_size
          next
        end
        @spritesheet.render x + col * @cell_size[0],
                            row_y,
                            z,
                            byte + offset,
                            color: @color
        col += 1
      end
    end
  end
end
