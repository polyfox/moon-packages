# :nodoc:
module Moon
  class Textbox < Widget
    # @param [Moon::Text]
    attr_reader :text

    ##
    #
    private def init_elements
      super
      @text = Text.new
      add(@text)
    end

    ##
    #
    private def init_events
      super
      on :typing do |e|
        @text.string += e.char
      end

      on :clear do
        @text.string.clear
      end

      on :press, :backspace do
        @text.string = @text.string.chop
      end

      on :resize do
        @text.position.y = (height - @text.line_height) / 2
      end
    end
  end
end
