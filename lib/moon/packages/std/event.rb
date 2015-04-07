module Moon
  # Base class for every other Event.
  class Event
    @@id = 0

    # @!attribute [r] type
    #   @return [Symbol] type of event
    attr_reader :type
    # @!attribute [r] id
    #   @return [Integer] id of the event
    attr_reader :id

    # @param [Symbol] type
    def initialize(type)
      @type = type
      @id = @@id += 1
    end
  end

  # Base class for Input related events.
  class InputEvent < Event
    # @!attribute [r] action
    #   @return [Symbol] state of the key, whether its :press, :release, or :repeat
    attr_reader :action
    # @!attribute [r] key
    #   @return [Symbol] name of the key
    attr_reader :key
    # @!attribute [r] mods
    #   @return [Integer] modifiers
    attr_reader :mods

    # @param [Symbol] key
    # @param [Symbol] action
    # @param [Integer] mods
    def initialize(key, action, mods)
      @action = action
      @key = key

      @mods = mods
      super @action
    end

    # Is the alt modifier active?
    def alt?
      @mods.masked? Moon::Input::MOD_ALT
    end

    # Is the control modifier active?
    def control?
      @mods.masked? Moon::Input::MOD_CONTROL
    end

    # Is the super/winkey modifier active?
    def super?
      @mods.masked? Moon::Input::MOD_SUPER
    end

    # Is the shift modifier active?
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
      @position / [@screen_rect.w, @screen_rect.h]
    end
  end
end
