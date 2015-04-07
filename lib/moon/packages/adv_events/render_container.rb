module Moon
  class RenderContainer
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

    # Sets the containers w.
    # This will trigger a +ResizeEvent+.
    #
    # @param [Integer] w
    # @return [Void]
    def w=(w)
      @w = w
      trigger ResizeEvent.new(self)
    end

    # Sets the containers h.
    # This will trigger a +ResizeEvent+.
    #
    # @param [Integer] h
    # @return [Void]
    def h=(h)
      @h = h
      trigger ResizeEvent.new(self)
    end

    # Resizes the container provided a w and h
    # This will trigger a +ResizeEvent+.
    #
    # @param [Integer] w
    # @param [Integer] h
    # @return [self]
    def resize(w, h)
      @w, @h = w, h
      trigger ResizeEvent.new(self)
      self
    end
  end
end
