module Moon #:nodoc:
  class Event #:nodoc:
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

  # An event used for wrapping other events.
  # This is not used on its own and is normally subclassed.
  class WrappedEvent < Event
    # @!attribute [r] original_event
    #   @return [Event] the original event
    attr_reader :original_event
    # @!attribute [r] parent
    #   @return [RenderContainer] parent render context of this event
    attr_reader :parent

    # @param [Event] event
    # @param [RenderContainer] parent
    def initialize(event, parent)
      @original_event = event
      @parent = parent
      super :wrap
    end
  end

  # Base event for state events.
  class WrappedStateEvent < WrappedEvent
    # @!attribute [r] state
    #   @return [Boolean] whether its hovering, or not
    attr_reader :state

    # @param [Event] event
    # @param [RenderContainer] parent
    # @param [Boolean] state
    def initialize(event, parent, state)
      @state = state
      super event, parent
    end
  end

  # An event triggered when the Mouse hovers over an Object.
  class MouseHoverEvent < WrappedStateEvent
  end

  # An event triggered when a Mouse click takes place inside an Object.
  class MouseFocusedEvent < WrappedEvent
  end

  # An event triggered when an Object resizes
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

  module Eventable #:nodoc:
    remove_method :alias_event
    remove_method :trigger_aliases
    remove_method :trigger_any

    # Structure for holding event listener information.
    class Listener
      # @!attribute [rw] klass
      #   @return [Class] event class object
      attr_accessor :klass
      # @!attribute [rw] filter
      #   @return [Proc] used to determine if the event is valid.
      attr_accessor :filter
      # @!attribute [rw] callback
      #   @return [Proc] function to call when the Event is triggered
      attr_accessor :callback

      # @param [Class] klass
      # @param [Proc] filter
      # @param [callback] callback
      def initialize(klass, filter, callback)
        @klass, @filter, @callback = klass, filter, callback
      end
    end

    # @param [Class] klass
    # @param [Hash] options
    # @yieldparam [Event] ev
    private def register_event(klass, options, &block)
      event_filter = klass.make_filter(options)
      listener = Listener.new(klass, event_filter, block)
      add_event_listener(klass, listener)
    end

    # @param [Class] klass
    # @param [Hash] options
    def on(klass, options = {}, &block)
      if klass.is_a?(Class)
        register_event(klass, options, &block)
      elsif klass.is_a?(Array)
        klass.each { |k| register_event(k, options, &block) }
      else
        puts "Ignoring event: #{klass}"
      end
    end

    def typing(&block)
      on(KeyboardTypingEvent, &block)
    end

    def trigger_event(event)
      event.class.ancestors.each do |klass|
        @event_listeners[klass].try(:each) do |listener|
          if listener.filter.call(event)
            listener.callback.call(event, self)
          end
        end
      end
    end

    ###
    # @param [Event] event
    ###
    def trigger(event)
      return unless event.is_a?(Event)
      #raise TypeError, "wrong argument type #{event.class} (expected #{Event})" unless event.is_a?(Event)
      return unless allow_event?(event)

      trigger_event(event)
    end
  end
end
