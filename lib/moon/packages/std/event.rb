module Moon
  # Base class for every other Event.
  class Event
    @@id = 0

    # @!attribute [r] type
    #   @return [Symbol] type of event
    attr_accessor :type
    # @!attribute [r] id
    #   @return [Integer] id of the event
    attr_accessor :id

    # @param [Symbol] type
    def initialize(type)
      @id = @@id += 1
      @type = type
    end
  end

  # Base class for Input related events.
  class InputEvent < Event
    # @!attribute [r] action
    #   @return [Symbol] state of the key, whether its :press, :release, or :repeat
    attr_accessor :action
    # @!attribute [r] key
    #   @return [Symbol] name of the key
    attr_accessor :key
    # @!attribute [r] mods
    #   @return [Integer] modifiers
    attr_accessor :mods

    alias :button :key
    alias :button= :key=

    # @param [Symbol] key
    # @param [Symbol] action
    # @param [Integer] mods
    def initialize(key, action, mods)
      @action = action
      super @action
      @key = key
      @mods = mods
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

  # Common module for all Keyboard*Events
  module KeyboardEvent
  end

  class KeyboardTypingEvent < Event
    include KeyboardEvent

    attr_accessor :char

    def initialize(char)
      @char = char
      super :typing
    end
  end

  class KeyboardInputEvent < InputEvent
    include KeyboardEvent
  end

  module MouseEvent
  end

  class MouseInputEvent < InputEvent
    include MouseEvent

    attr_accessor :action
    attr_accessor :position
    attr_accessor :relative

    def initialize(button, action, mods, position)
      @position = position
      @relative = position
      super button, action, mods
    end
  end

  class MouseMoveEvent < Event
    include MouseEvent

    attr_reader :x
    attr_reader :y
    attr_accessor :screen_rect

    def initialize(x, y, screen_rect)
      @screen_rect = screen_rect
      @x, @y = x, y
      super :mousemove
    end

    def x=(x)
      @x = x
      @position = nil
      @normalize_position = nil
    end

    def y=(y)
      @y = y
      @position = nil
      @normalize_position = nil
    end

    def position
      @position ||= Moon::Vector2.new(@x, @y)
    end

    def position=(pos)
      @position = pos
      @x, @y = *@position
      @normalize_position = nil
    end

    def normalize_position
      @normalize_position ||= position / [@screen_rect.w, @screen_rect.h]
    end
  end

  class ClickEvent < Event
    attr_accessor :target
    attr_accessor :position

    def initialize(target, position)
      @target = target
      @position = position
      super :click
    end
  end

  # Event used for wrapping other events.
  # This is not used on its own and is normally subclassed.
  # @abstract
  class WrappedEvent < Event
    # @!attribute [r] original_event
    #   @return [Event] the original event
    attr_accessor :original_event
    # @!attribute [r] parent
    #   @return [RenderContainer] parent render context of this event
    attr_accessor :parent

    # @param [Event] event
    # @param [RenderContainer] parent
    # @param [Symbol] type  the event type
    def initialize(event, parent, type)
      @original_event = event
      @parent = parent
      super type
    end
  end

  # Base event for stateful mouse events.
  # @abstract
  class MouseWrappedStateEvent < WrappedEvent
    include MouseEvent

    # @!attribute state
    #   @return [Boolean] whether its hovering, or not
    attr_accessor :state

    # @!attribute position
    #   @return [Vector2] position
    attr_accessor :position

    # @param [Event] event
    # @param [RenderContainer] parent
    # @param [Vector2] position
    # @param [Boolean] state  true if the mouse is hovering over the object,
    #                         false otherwise
    # @param [Symbol] type  the event type
    def initialize(event, parent, position, state, type)
      @position = Moon::Vector2[position]
      @state = state
      super event, parent, type
    end
  end

  # Event triggered when the Mouse hovers over an Object.
  class MouseHoverEvent < MouseWrappedStateEvent
    def initialize(event, parent, position, state)
      super event, parent, position, state, :mousehover
    end
  end

  # Event triggered when a Mouse click takes place inside an Object.
  class MouseFocusedEvent < MouseWrappedStateEvent
    def initialize(event, parent, position, state)
      super event, parent, position, state, :mousefocus
    end
  end

  # Event triggered when an Object resizes
  class ResizeEvent < Event
    # @!attribute [r] parent
    #   @return [RenderContainer] parent render context of this event
    attr_accessor :parent

    # @param [RenderContainer] parent
    def initialize(parent)
      @parent = parent
      super :resize
    end
  end
end
