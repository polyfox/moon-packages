require 'render_primitives/render_context'

module Moon
  # Renderer object for rendering Fonts
  class Text < RenderContext
    # A StringChangedEvent is triggered when the Text#string changes, note
    # this event will trigger even if the String's value is the same.
    class StringChangedEvent < Event
      # @!attribute [rw] old
      #   @return [String] original value of the string
      attr_accessor :old
      # @!attribute [rw] string
      #   @return [String] current value of the string
      attr_accessor :string

      # @param [String] old
      # @param [String] string
      def initialize(old, string)
        @old = old
        @string = string
        super :text_string_changed
      end
    end

    # A FontChangedEvent is triggered when the Text#font changes, note
    # this event will trigger event if the Font's value is the same.
    class FontChangedEvent < Event
      # @!attribute [rw] old
      #   @return [Font] original font
      attr_accessor :old
      # @!attribute [rw] string
      #   @return [Font] current font
      attr_accessor :font

      # @param [Font] old
      # @param [Font] font
      def initialize(old, font)
        @old = old
        @font = font
        super :text_font_changed
      end
    end

    # @return [Moon::Vector4]
    attr_reader   :color

    # @return [Numeric] outline  outline size, 0 or less is disabled
    attr_reader   :outline

    # @return [Moon::Vector4]
    attr_accessor :outline_color

    # @return [Moon::Font]
    attr_reader   :font

    # @return [Float]
    attr_reader   :opacity

    # @return [Symbol] position options are :left, :right, or :center
    attr_accessor :align

    # @return [String]
    attr_reader   :string

    # @return [Float]
    attr_accessor :line_h

    # @param [String] string
    # @param [Moon::Font] font
    def initialize(string = nil, font = nil, align = :left)
      @lines = []
      @font = font
      @align = align
      @outline = 0
      @outline_color = Vector4.new(0.0, 0.0, 0.0, 0.0)
      @line_h = 1.2
      @opacity = 1.0
      super()
      self.color = Vector4.new(1.0, 1.0, 1.0, 1.0)
      self.string = string
    end

    def on_opacity_changed(org, cur)
      refresh_opacity
    end

    def on_color_changed(org, cur)
      refresh_color
    end

    def on_outline_changed(org, cur)
      refresh_size
    end

    def on_font_changed(org, cur)
      refresh_size
      trigger { FontChangedEvent.new(org, cur) }
    end

    def on_string_changed(org, cur)
      @lines = @string.split("\n")
      refresh_size
      trigger { StringChangedEvent.new(org, cur) }
    end

    # @attribute [w] opacity
    def opacity=(opacity)
      old = @opacity
      @opacity = opacity
      on_opacity_changed old, @opacity
    end

    # @attribute [w] outline
    def outline=(outline)
      old = @outline
      @outline = outline
      on_outline_changed old, @outline
    end

    # @attribute [w] color
    def color=(color)
      old = @color
      @color = color
      on_color_changed old, @color
    end

    # @attribute [w] font
    def font=(font)
      old = @font
      @font = font
      on_font_changed old, @font
    end

    # @attribute [w] string
    def string=(string)
      old = @string
      @string = string.to_s
      on_string_changed old, @string
    end

    # @param [Hash<Symbol, Object>] options
    def set(options)
      self.string = options.fetch(:string)
      self.align = options.fetch(:align, :left)
      self.color = options.fetch(:color) { Moon::Vector4.new(1, 1, 1, 1) }
      if fon = options[:font]
        self.font = fon
      end
      self
    end

    # @return [Float]
    private def font_line_h
      @font.size * @line_h
    end

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
          if op = options.delete(:opacity)
            rc = rc.dup
            rc.a *= op
          end
          font.render(x, y + index * font_line_h, z,
                      line, rc, {
                        outline: @outline,
                        outline_color: @outline_color
                      }.merge(options))
        end
      end
    end

    #
    private def refresh_size
      if @font && @string
        vec2 = Vector2.new(0, 0)
        @lines.each do |line|
          bounds = @font.calc_bounds(line)
          vec2.x = bounds[0] if vec2.x < bounds[0]
          vec2.y = bounds[1] if vec2.y < bounds[1]
          vec2.y += [font_line_h, bounds[1]].max
          vec2.y += @outline # compensate for outline
          vec2
        end
        resize(*vec2.floor)
      else
        resize 0, 0
      end
    end

    #
    private def refresh_opacity
      refresh_color
    end

    #
    private def refresh_color
      @render_color = Vector4.new(@color.r, @color.g, @color.b, @color.a)
      @render_color.a *= @opacity
    end
  end
end
