# :nodoc:
module Moon
  class Button < Widget
    # @return [Moon::Text]
    attr_reader :text

    ##
    #
    def init_elements
      super
      @text = Text.new
      add(@text)
    end
  end
end
