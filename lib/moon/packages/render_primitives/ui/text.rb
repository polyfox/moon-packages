# :nodoc:
module Moon
  ##
  # Renderer object for rendering Fonts
  class Text < RenderContext
    # @return [Moon::Vector4]
    attr_reader   :color
    # @return [Moon::Font]
    attr_reader   :font
    # @return [Float]
    attr_reader   :opacity
    # @return [Symbol]
    #   @enum [:left, :right, :center]
    attr_accessor :align
    # @return [String]
    attr_reader   :string
    # @return [Integer]
    attr_reader   :w
    # @return [Integer]
    attr_reader   :h
    # @return [Float]
    attr_accessor :line_h

    ##
    # @param [String] string
    # @param [Moon::Font] font
    def initialize(string = nil, font = nil, align = :left)
      @lines = []
      @font = font
      @align = align
      @line_h = 1.2
      @opacity = 1.0
      super()
      self.color = Vector4.new(1.0, 1.0, 1.0, 1.0)
      self.string = string
    end

    ##
    # @attribute [w] opacity
    def opacity=(opacity)
      @opacity = opacity
      refresh_opacity
    end

    ##
    # @attribute [w] color
    def color=(color)
      @color = color
      refresh_color
    end

    ##
    # @attribute [w] font
    def font=(font)
      @font = font
      refresh_size
    end

    ##
    # @attribute [w] string
    def string=(string)
      @string = string.to_s
      @lines = @string.split("\n")
      refresh_size
    end

    ##
    # @param [Hash<Symbol, Object>] options
    def set(options)
      self.string = options.fetch(:string)
      self.align = options.fetch(:align, :left)
      if fon = options[:font]
        self.font = fon
      end
      self
    end

    ##
    # @return [Float]
    private def font_line_h
      @font.size * @line_h
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    private def render_content(x, y, z, options)
      if @font && @string
        @lines.each_with_index do |line, index|
          case @align
          when :left
            # do nothing
          when :right
            x -= @font.calc_bounds(line)[0]
          when :center
            x -= @font.calc_bounds(line)[0] / 2
          end

          rc = @render_color
          if op = options[:opacity]
            rc = rc.dup
            rc.a *= op
          end
          font.render(x, y + index * font_line_h, z,
                      line, rc, options)
        end
      end
      super
    end

    ##
    #
    private def refresh_size
      if @font && @string
        vec2 = Vector2.new(0, 0)
        @lines.each do |line|
          bounds = @font.calc_bounds(line)
          vec2.x = bounds[0] if vec2.x < bounds[0]
          vec2.y = bounds[1] if vec2.y < bounds[1]
          vec2.y += [font_line_h, bounds[1]].max
          vec2.y += 2 # compensate for outline
          vec2
        end
        @w, @h = *vec2.floor
      else
        @w, @h = 0, 0
      end
    end

    ##
    #
    private def refresh_opacity
      refresh_color
    end

    ##
    #
    private def refresh_color
      @render_color = Vector4.new(@color.r, @color.g, @color.b, @color.a)
      @render_color.a *= @opacity
    end
  end
end
