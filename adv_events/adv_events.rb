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

  class RenderContainer
    def init_events
      # generic event passing callback
      # this callback will trigger the passed event in the children elements
      # Input::MouseEvent are handled specially, since it requires adjusting
      # the position of the event
      on Moon::Event do |event|
        @elements.each do |element|
          element.trigger event
        end
      end
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

    def on(klass, options={}, &block)
      if klass.is_a?(Class)
        event_filter = klass.make_filter(options)
        listener = Listener.new(klass, event_filter, block)
        (@event_listeners[klass] ||= []).push(listener)
      else
        puts "Ignoring event: #{klass}"
      end
    end

    def typing(&block)
      on(KeyboardTypingEvent, &block)
    end

    def trigger_event(event)
      #puts "#{event}"
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
