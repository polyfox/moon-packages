# :nodoc:
module Moon
  ##
  # Widget base class
  class Widget < RenderContainer
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
      on :resize do
        @background.width = width
        @background.height = height
      end
    end

    ##
    #
    private def create_background
      @background = SkinSlice9.new
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
