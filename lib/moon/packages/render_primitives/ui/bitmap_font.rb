# :nodoc:
module Moon
  ##
  # Renderer object, for rendering bitmap font Spritesheets
  class BitmapFont < Moon::RenderContext
    # @return [String]
    attr_reader :string
    # @return [Boolean]
    attr_accessor :bold
    # @return [Moon::Vector4]
    attr_accessor :color

    ##
    # @param [Moon::Spritesheet] spritesheet
    # @param [String] string initial ASCII string value
    # @param [Hash<Symbol, Object>] options
    def initialize(spritesheet, string = '', options = {})
      super(options)
      @color = Vector4.new(1.0, 1.0, 1.0, 1.0)
      @spritesheet = spritesheet
      self.string = string
    end

    ##
    # @param [String] string
    def string=(string)
      @string = (string && string.to_s) || nil
      refresh_size
    end

    ##
    # Recalculate size
    private def refresh_size
      @cached_w = @string.size * @spritesheet.w
      @cached_h = (@string.count("\n") + 1) * @spritesheet.h

      self.w = @cached_w
      self.h = @cached_h
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    private def render_content(x, y, z, options)
      if @string
        offset = @bold ? 256 : 0
        row = 0
        col = 0

        @string.each_byte do |byte|
          if byte.chr == "\n"
            col = 0
            row += 1
            next
          end
          @spritesheet.render x + col * @cell_size[0],
                              y + row * @cell_size[1],
                              z,
                              byte + offset,
                              color: @color
          col += 1
        end
      end
      super
    end
  end
end
