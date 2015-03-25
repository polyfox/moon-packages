module Lunar #:nodoc:
  ##
  # Widget base class
  class Widget < Moon::RenderContainer
    # @return [Boolean]
    attr_accessor :focused
    # @return [Moon::SkinSlice9]
    attr_reader :background

    ##
    #
    def init
      @focused = false
      super
    end

    ##
    #
    private def init_elements
      super
      create_background
    end

    ##
    #
    private def init_events
      super
      init_widget_events
    end

    private def init_widget_events
      on :resize do
        @background.width = width
        @background.height = height
      end
    end

    ##
    #
    private def create_background
      @background = Moon::SkinSlice9.new
      add(@background)
    end

    ##
    #
    def focus
      @focused = true
    end

    ##
    #
    def unfocus
      @focused = false
    end
  end
end
