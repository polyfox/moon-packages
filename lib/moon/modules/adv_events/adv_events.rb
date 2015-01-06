module Moon
  class Event
    def self.make_filter(options)
      lambda do |event|
        options.all? do |k, v|
          event.send(k) == v
        end
      end
    end
  end

  class WrapEvent < Event
    attr_accessor :original_event
    attr_accessor :parent

    def initialize(event, parent)
      @original_event = event
      @parent = parent
      super :wrap
    end
  end

  class MouseHoverEvent < WrapEvent
    attr_reader :state

    def initialize(event, parent, state)
      @state = state
      super event, parent
    end
  end

  class MouseFocusedEvent < WrapEvent
    attr_reader :state

    def initialize(event, parent, state)
      @state = state
      super event, parent
    end
  end

  class RenderContainer
    class ResizeEvent < Event
      attr_accessor :parent

      def initialize(parent)
        @parent = parent
        super :resize
      end
    end

    def init_events
      ##
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
        trigger MouseFocusedEvent.new(event, self, screen_bounds.inside?(event.position))
      end

      on Moon::MouseMove do |event|
        trigger MouseHoverEvent.new(event, self, screen_bounds.inside?(event.position))
      end
    end

    def width=(width)
      @width = width
      trigger ResizeEvent.new(self)
    end

    def height=(height)
      @height = height
      trigger ResizeEvent.new(self)
    end

    def resize(w, h)
      @width, @height = w, h
      trigger ResizeEvent.new(self)
      self
    end
  end

  module Eventable
    remove_method :alias_event
    remove_method :trigger_aliases
    remove_method :trigger_any

    class Listener
      attr_accessor :klass
      attr_accessor :filter
      attr_accessor :callback

      def initialize(klass, filter, callback)
        @klass, @filter, @callback = klass, filter, callback
      end
    end

    private def register_event(klass, options, &block)
      event_filter = klass.make_filter(options)
      listener = Listener.new(klass, event_filter, block)
      add_event_listener(klass, listener)
    end

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
