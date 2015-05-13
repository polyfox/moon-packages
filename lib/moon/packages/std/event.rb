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
      @type = type
      @id = @@id += 1
    end

    # Creates a filter proc for handling extra options from an Eventable#on
    #
    # @param [Hash<Symbol, Object>] options  used for filter.
    # @return [Proc]
    def self.make_filter(options)
      lambda do |event|
        # Checks that all pairs in the options match the event's properties.
        #
        # @example KeyboardEvent with key
        #   # this will filter KeyboardEvents with the :press action and :a key.
        #   on Moon::KeyboardEvent, action: :press, key: :a do |ev|
        #     do_action ev
        #   end
        options.all? do |k, v|
          event.send(k) == v
        end
      end
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
    attr_accessor :char
    attr_accessor :action

    def initialize(char)
      @char = char
      @action = :typing
      super @action
    end
  end

  class KeyboardEvent < InputEvent
  end

  class MouseEvent < InputEvent
    attr_accessor :action
    attr_accessor :position
    attr_accessor :relative

    def initialize(button, action, mods, position)
      @position = Vector2[position]
      @relative = Vector2[position]
      super button, action, mods
    end
  end

  class MouseMoveEvent < Event
    attr_accessor :screen_rect
    attr_accessor :position
    attr_accessor :relative

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

  # Base event for stateful events.
  # @abstract
  class WrappedStateEvent < WrappedEvent
    # @!attribute [r] state
    #   @return [Boolean] whether its hovering, or not
    attr_accessor :state

    # @param [Event] event
    # @param [RenderContainer] parent
    # @param [Boolean] state
    # @pa
    def initialize(event, parent, state, type)
      @state = state
      super event, parent, type
    end
  end

  # Event triggered when the Mouse hovers over an Object.
  class MouseHoverEvent < WrappedStateEvent
    # @param [Event] event
    # @param [RenderContainer] parent
    # @param [Boolean] state  true if the mouse is hovering over the object,
    #                         false otherwise
    def initialize(event, parent, state)
      super event, parent, state, :mousehover
    end
  end

  # Event triggered when a Mouse click takes place inside an Object.
  class MouseFocusedEvent < WrappedStateEvent
    # @param [Event] event
    # @param [RenderContainer] parent
    # @param [Boolean] state  true if the mouse is focused on the object,
    #                         false otherwise
    def initialize(event, parent, state)
      super event, parent, state, :mousefocus
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
