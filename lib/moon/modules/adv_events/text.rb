module Moon #:nodoc:
  class Text #:nodoc:
    # @!attribute [rw] use_events
    #   @return [Boolean]
    attr_accessor :use_events
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
        super :string_changed
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
        super :font_changed
      end
    end

    # Enables events for this Text object
    def enable_events
      @use_events = true
    end

    # Disable events for this Text object
    def disable_events
      @use_events = false
    end

    alias :set_string_wo_event :string=
    # @param [String] string
    def string=(string)
      old = @string
      set_string_wo_event(string)
      trigger(StringChangedEvent.new(old, self.string)) if @use_events
    end

    alias :set_font_wo_event :font=
    # @param [Font] font
    def font=(font)
      old = @font
      set_font_wo_event(font)
      trigger(FontChangedEvent.new(old, self.font)) if @use_events
    end
  end
end
