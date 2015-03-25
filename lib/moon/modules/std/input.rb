module Moon
  class Input
    private def channels
      @channels ||= Set.new
    end

    def register(channel)
      channels.push channel
    end

    def unregister(channel)
      channels.delete channel
    end

    def trigger(event)
      channels.each do |channel|
        channel.trigger event
      end
    end

    def on_key(key, _, action, mods)
      trigger KeyboardEvent.new(key, action, mods)
    end

    def on_button(button, action, mods)
      trigger MouseEvent.new(button, action, mods, @mouse.position)
    end

    def on_type(char)
      trigger KeyboardTypingEvent.new(char)
    end

    def on_mousemove(x, y)
      trigger MouseMove.new(x, y, @engine.screen.rect)
    end
  end

  class Input::Mouse
    def in_area?(x, y, width, height)
      self.x.between?(x, x + width) && self.y.between?(y, y + height)
    end

    def in_rect?(rect)
      in_area? rect.x, rect.y, rect.width, rect.height
    end
  end
end
