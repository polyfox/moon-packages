module Moon #:nodoc:
  class RenderContainer #:nodoc:
    # @return [Void]
    private def init_events
      # generic event passing callback
      # this callback will trigger the passed event in the children elements
      # Input::MouseEvent are handled specially, since it requires adjusting
      # the position of the event
      on Moon::Event do |event|
        @elements.each do |element|
          element.trigger event
        end
      end

      on Moon::MouseEvent do |event|
        p = event.position
        trigger MouseFocusedEvent.new(event, self, screen_bounds.contains?(p.x, p.y))
      end

      on Moon::MouseMove do |event|
        p = event.position
        trigger MouseHoverEvent.new(event, self, screen_bounds.contains?(p.x, p.y))
      end
    end

    # Sets the containers width.
    # This will trigger a +ResizeEvent+.
    #
    # @param [Integer] width
    # @return [Void]
    def width=(width)
      @width = width
      trigger ResizeEvent.new(self)
    end

    # Sets the containers height.
    # This will trigger a +ResizeEvent+.
    #
    # @param [Integer] height
    # @return [Void]
    def height=(height)
      @height = height
      trigger ResizeEvent.new(self)
    end

    # Resizes the container provided a width and height
    # This will trigger a +ResizeEvent+.
    #
    # @param [Integer] w
    # @param [Integer] h
    # @return [self]
    def resize(w, h)
      @width, @height = w, h
      trigger ResizeEvent.new(self)
      self
    end
  end
end
