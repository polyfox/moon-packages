module Moon
  class Text
    class StringChangedEvent < Event
      attr_accessor :string

      def initialize(string)
        @string = string
        super :string_changed
      end
    end

    class FontChangedEvent < Event
      attr_accessor :font

      def initialize(font)
        @font = font
        super :font_changed
      end
    end

    def enable_events
      @use_events = true
    end

    def disable_events
      @use_events = false
    end

    alias :set_string_wo_event :string=
    def string=(string)
      set_string_wo_event(string)
      trigger(StringChangedEvent.new(self.string)) if @use_events
    end

    alias :set_font_wo_event :font=
    def font=(font)
      set_font_wo_event(font)
      trigger(FontChangedEvent.new(self.font)) if @use_events
    end
  end
end
