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

    def w
      @w ||= @text.w
    end

    def h
      @h ||= @text.h
    end

    def font
      @text.font
    end

    def font=(font)
      org = @text.font
      @text.font = font
      resize nil, nil
      trigger { FontChangedEvent.new(org, @text.font) }
    end

    def string
      @text.string
    end

    def string=(string)
      org = @text.string
      @text.string = string
      resize nil, nil
      trigger { StringChangedEvent.new(org, @text.string) }
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
      resize nil, nil
    end

    # @return [Symbol] position options are :left, :right, or :center
    def align
      @text.align
    end

    def align=(align)
      org = @text.align
      @text.align = align
      trigger { FontChangedEvent.new(org, @text.align) }
    end

    def line_height
      @text.line_height
    end

    def line_height=(line_height)
      @text.line_height = line_height
      resize nil, nil
    end

    def render_content(x, y, z)
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
