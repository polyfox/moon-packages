module Lunar #:nodoc:
  class Label < Widget
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
