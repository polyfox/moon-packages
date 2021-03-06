module Moon
  # Input extension for using Moon::Events
  class Input
    # @return [Set]
    private def channels
      @channels ||= Moon::Set.new
    end

    def register(channel)
      channels.push channel
    end

    def unregister(channel)
      channels.delete channel
    end

    def trigger(event = nil)
      return if channels.empty?
      event = yield if block_given?
      channels.each do |channel|
        channel.call event
      end
    end

    def on_key(key, _, action, mods)
      trigger { KeyboardInputEvent.new(key, action, mods) }
    end

    def on_button(button, action, mods)
      trigger { MouseInputEvent.new(button, action, mods, @mouse.position) }
    end

    def on_type(char)
      trigger { KeyboardTypingEvent.new(char) }
    end

    def on_mousemove(x, y)
      trigger { MouseMoveEvent.new(x, y) }
    end
  end

  class Input::Mouse
    def in_area?(x, y, w, h)
      self.x.between?(x, x + w) && self.y.between?(y, y + h)
    end

    def in_rect?(rect)
      in_area? rect.x, rect.y, rect.w, rect.h
    end
  end
end
