module Moon
  module Eventable
    # Structure for holding event listener information.
    class Listener
      # @!attribute [rw] event
      #   @return [Class, Symbol] event
      attr_accessor :event

      # @!attribute [rw] filter
      #   @return [Proc] used to determine if the event is valid.
      attr_accessor :filter

      # @!attribute [rw] callback
      #   @return [Proc] function to call when the Event is triggered
      attr_accessor :callback

      # @param [Class] event
      # @param [Proc] filter
      # @param [callback] callback
      def initialize(event, filter, callback)
        @event, @filter, @callback = event, filter, callback
      end
    end

    def self.filter_from_options(args)
      return ->(event) { true } if args.empty?

      # #on's originally form expected that the args Array would be a list of
      # "keys" for Keyboard or Mouse Events
      opts = args.first
      if args.size > 1 || opts.is_a?(Symbolic) || opts.is_a?(Array)
        keys = args.flatten.map(&:to_sym)
        # adv_events uses a lambda / proc to determine if an Event should
        # be accepted by the listener
        # Here we are creating a lambda that takes an event, using the
        # keys from the #on, it checks if ANY of the keys matches event's key.
        ->(event) { keys.any? { |key| event.key == key } }
      else
        # on the other hand, adv_events expected a Hash with key value pairs
        # to check against the event's attributes

        # if the user provided a Proc as the argument, then treat it as
        # the filter
        if opts.is_a?(Proc)
          opts
        # if the user provided an options hash, with a filter key, treat
        # as the filter
        elsif f = opts[:filter]
          f
        # otherwise, make a filter using the provided options
        else
          Event.make_filter(opts)
        end
      end
    end

    def initialize_eventable
      clear_events
    end

    def clear_events
      @typed_listeners = {}
      @classed_listeners = {}
    end

    def each_listener
      @typed_listeners.each do |key, value|
        yield key, value
      end
      @classed_listeners.each do |klass, value|
        yield klass, value
      end
    end

    # @param [Moon::Event] event
    # @return [Boolean]
    def allow_event?(event)
      true
    end

    # Adds a new event listener.
    #
    # @param [Symbol] keys The keys to listen for..
    # @param [Proc] block The block we want to execute when we catch the type.
    def on(events, *args, &block)
      filter = Eventable.filter_from_options(args)

      # if the event isn't an Array, make one, this allows the user to specify
      # multiple events with the same options
      events = [events] unless events.is_a?(Array)

      # add each listener object to the
      listeners = events.map do |event|
        add_listener(event, Listener.new(event, filter, block))
      end

      listeners.singularize
    end

    # Used to retrieve the correct listeners for a event
    # (either by Class or Symbol)
    private def get_listeners_for_event(event)
      if event.is_a?(Class)
        @classed_listeners
      else
        @typed_listeners
      end
    end

    # @return [Symbol] event
    # @return [Hash] listener
    def add_listener(event, listener)
      listeners = get_listeners_for_event(event)
      (listeners[event] ||= []).push(listener)
      listener
    end

    def typing(&block)
      on(:typing, &block)
    end

    private def trigger_listeners(listeners, event)
      listeners.each do |listener|
        next unless listener.filter.call(event)
        listener.callback.call(event, self)
      end
    end

    private def trigger_typed_events(type, event)
      return if @typed_listeners.empty?
      (listeners = @typed_listeners[type]) && trigger_listeners(listeners, event)
    end

    private def trigger_classed_events(event)
      return if @classed_listeners.empty?
      @classed_listeners.each do |klass, listeners|
        next unless klass === event
        trigger_listeners(listeners, event)
      end
    end

    private def trigger_event(type, event)
      trigger_typed_events(type, event)
      trigger_classed_events(event)
    end

    private def trigger_any(event)
      trigger_event(:any, event)
    end

    # @param [Event] event
    def trigger(event)
      event = Event.new(event) unless event.is_a?(Event)

      return unless allow_event?(event)

      trigger_any(event)
      trigger_event(event.type, event)
    end
  end
end
