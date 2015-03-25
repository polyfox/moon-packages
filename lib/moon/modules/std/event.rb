module Moon
  class Event
    @@id = 0

    attr_reader :type
    attr_reader :id

    def initialize(type)
      @type = type
      @id = @@id += 1
    end
  end

  class InputEvent < Event
    attr_reader :action, :key, :mods

    def initialize(key, action, mods)
      @action = action
      @key = key

      @mods = mods
      super @action
    end

    def alt?
      @mods.masked? Moon::Input::MOD_ALT
    end

    def control?
      @mods.masked? Moon::Input::MOD_CONTROL
    end

    def super?
      @mods.masked? Moon::Input::MOD_SUPER
    end

    def shift?
      @mods.masked? Moon::Input::MOD_SHIFT
    end
  end

  class KeyboardTypingEvent < Event
    attr_reader :char
    attr_reader :action

    def initialize(char)
      @char = char
      @action = :typing
      super @action
    end
  end

  class KeyboardEvent < InputEvent
  end

  class MouseEvent < InputEvent
    attr_reader :action
    attr_accessor :position
    attr_accessor :relative

    def initialize(button, action, mods, position)
      @position = Vector2[position]
      @relative = Vector2[position]
      super button, action, mods
    end
  end

  class MouseMove < Event
    attr_reader :screen_rect
    attr_reader :position
    attr_reader :relative

    def initialize(x, y, screen_rect)
      @screen_rect = screen_rect
      @position = Vector2.new(x, y)
      @relative = Vector2.new(x, y)
      super :mousemove
    end

    def normalize_position
      @position / [@screen_rect.width, @screen_rect.height]
    end
  end
end
