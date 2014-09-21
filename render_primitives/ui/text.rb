module Moon
  class Text < RenderContext
    attr_reader   :color       # Moon::Vector4
    attr_reader   :font        # Moon::Font
    attr_reader   :opacity     # Float
    attr_accessor :align       # Symbol [:left, :right, :center]
    attr_reader   :string      # String
    attr_reader   :width       # Integer
    attr_reader   :height      # Integer
    attr_accessor :line_height # Float

    def opacity=(new_opacity)
      @opacity = new_opacity
      refresh_opacity
    end

    def color=(new_color)
      @color = new_color
      refresh_color
    end

    def font=(new_font)
      @font = new_font
      refresh_size
    end

    def string=(new_string)
      @string = new_string.to_s
      @lines = @string.split("\n")
      refresh_size
    end

    def initialize(string=nil, font=nil, align=:left)
      @lines = []
      @font = font
      @align = align
      @line_height = 1.2
      @opacity = 1.0
      super()
      self.color = Vector4.new(1.0, 1.0, 1.0, 1.0)
      self.string = string
    end

    def set(options)
      self.string = options.fetch :string
      self.align = options.fetch :align, :left
      if fon = options[:font]
        self.font = fon
      end
      self
    end

    def line_height
      @font.size * @line_height
    end

    def render(x=0, y=0, z=0, options={})
      if @font && @string
        @lines.each_with_index do |line, index|
          pos = @position + [x, y, z]

          case @align
          when :left
            # do nothing
          when :right
            pos.x -= @font.calc_bounds(line)[0]
          when :center
            pos.x -= @font.calc_bounds(line)[0] / 2
          end

          font.render(pos.x, pos.y + index * line_height, pos.z,
                      line, @render_color, options)
        end
      end
      super x, y, z
    end

    def refresh_size
      if @font && @string
        vec2 = Vector2.new(0, 0)
        @lines.each do |line|
          bounds = @font.calc_bounds(line)
          vec2.x = bounds[0] if vec2.x < bounds[0]
          vec2.y = bounds[1] if vec2.y < bounds[1]
          vec2.y += [line_height, bounds[1]].max
          vec2.y += 2 # compensate for outline
          vec2
        end
        @width, @height = *vec2.floor
      else
        @width, @height = 0, 0
      end
    end

    def refresh_opacity
      refresh_color
    end

    def refresh_color
      @render_color = Vector4[@color]
      @render_color.a *= @opacity
    end
  end
end
