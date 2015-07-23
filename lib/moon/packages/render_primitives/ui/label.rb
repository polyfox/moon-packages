require 'render_primitives/render_context'

module Moon
  # Wrapper class around Moon::Text for backwards compatability
  class Label < RenderContext
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

    # @return [Float]
    attr_reader :opacity

    # @return [Vector4]
    attr_reader :color

    def initialize(string, font, options = {})
      super()
      @opacity = options.fetch(:opacity, 1.0)
      @text = Moon::Text.new(font, string, options)
      @color = @text.color.dup
      refresh_color
    end

    private def refresh_color
      @render_color = Vector4.new(@color.r, @color.g, @color.b, @color.a)
      @render_color.a *= @opacity
      @text.color = @render_color
    end

    def font
      @text.font
    end

    def font=(font)
      @text.font = font
      trigger { FontChangedEvent.new(org, cur) }
    end

    def string
      @text.string
    end

    def string=(string)
      @text.string = string
      trigger { StringChangedEvent.new(org, cur) }
    end

    def color=(color)
      @color = color
      refresh_color
    end

    def opacity=(opacity)
      @opacity = opacity
      refresh_color
    end

    def outline_color
      @text.outline_color
    end

    def outline_color=(outline_color)
      @text.outline_color = outline_color
    end

    def outline
      @text.outline
    end

    def outline=(outline)
      @text.outline = outline
    end

    # @return [Symbol] position options are :left, :right, or :center
    def align
      @text.align
    end

    def align=(align)
      @text.align = align
      trigger { FontChangedEvent.new(org, cur) }
    end

    def line_height
      @text.line_height
    end

    def line_height=(line_height)
      @text.line_height = line_height
    end

    def render_content(x, y, z, options)
      @text.render x, y, z
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
  end
end
