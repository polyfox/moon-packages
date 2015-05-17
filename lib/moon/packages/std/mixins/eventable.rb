require 'std/core_ext/array'
require 'std/core_ext/symbolic'
require 'std/event'

module Moon
  module Eventable
    # Structure for holding event listener information.
    class Listener
      # @!attribute [rw] type
      #   @return [Class, Symbol] type
      attr_accessor :type

      # @!attribute [rw] filter
      #   @return [Proc] used to determine if the event is valid.
      attr_accessor :filter

      # @!attribute [rw] callback
      #   @return [Proc] function to call when the Event is triggered
      attr_accessor :callback

      # @param [Class] type
      # @param [Proc] filter
      # @param [callback] callback
      def initialize(type, filter, callback)
        @type, @filter, @callback = type, filter, callback
      end

      def invoke(event, obj)
        return unless @filter.call(event)
        @callback.call(event, obj)
      end
    end

    # Creates a filter proc from the given args
    #
    # @param [Array] args
    # @return [Proc]
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

        if opts.is_a?(Hash)
          # if the user provided an options hash, with a filter key, treat
          # as the filter, otherwise, make a filter using the provided options
          opts.fetch(:filter) { Event.make_filter(opts) }
        else
          # otherwise, the object is treated as something callable
          opts
        end
      end
    end

    def initialize_eventable
      clear_events
    end

    # Clears all event listeners
    def clear_events
      @typed_listeners = {}
      @classed_listeners = {}
    end

    # @param [Class, Symbol] type
    # @yieldparam [Class, Symbol] type
    # @yieldparam [Listener] listener
    # @return [Enumerator] unless a block is given
    def each_typed_listener(type = nil, &block)
      return to_enum(:each_typed_listener, type) unless block_given?
      return if @typed_listeners.empty?
      if type
        if listeners = @typed_listeners[type]
          listeners.each { |listener| block.call type, listener }
        end
      else
        @typed_listeners.each do |key, listeners|
          listeners.each { |listener| block.call key, listener }
        end
      end
    end

    # @yieldparam [Symbol, Class, Event] event  event to filter with
    # @yieldparam [Listener] listener
    def each_listener(event = nil, &block)
      return to_enum(:each_listener, event) unless block_given?
      if event.is_a?(Event)
        type = event.type
      else
        type = event
        event = nil
      end

      each_typed_listener(type, &block)

      unless @classed_listeners.empty?
        @classed_listeners.each do |klass, listeners|
          if event   then next unless klass === event
          elsif type then next unless klass == type
          end
          listeners.each { |listener| block.call klass, listener }
        end
      end
    end

    # @return [Boolean] are there any active event listeners?
    def has_events?
      !@classed_listeners.empty? || !@typed_listeners.empty?
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

    # @param [Symbol] event
    # @param [Hash] listener
    # @return [Listener] listener
    private def add_listener(event, listener)
      listeners = get_listeners_for_event(event)
      (listeners[event] ||= []).push(listener)
      listener
    end

    # @!group Registration

    # Removes the listeners listed
    #
    # @param [Array<Moon::Listener>] listeners
    def off(*listeners)
      listeners.each do |listener|
        @classed_listeners.delete(listener.type)
        @typed_listeners.delete(listener.type)
      end
      listeners
    end

    # Adds a new event listener.
    #
    # @param [Symbol, Class<Event>] events  events to listen for
    # @param [Object] args  extra options
    # @param [Proc] block The block we want to execute when we catch the type.
    # @return [Listener]
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

    # Shortcut for `on :typing, &block`
    #
    # @return [Listener]
    def typing(&block)
      on(:typing, &block)
    end
    # @!endgroup Registration

    private def trigger_event(event)
      each_listener(event) { |_, listener| listener.invoke(event, self) }
    end

    private def trigger_any(event)
      each_typed_listener(:any) { |_, listener| listener.invoke(event, self) }
    end

    # Does this Eventable allow the event?
    #
    # @param [Moon::Event] event
    # @return [Boolean]
    def allow_event?(event)
      true
    end

    # Triggers an Event.
    # For backwards compatability, trigger can also take a Symbol as an
    # event, however, it will not trigger any Class based listeners.
    #
    # @param [Event] event
    def trigger(event = nil)
      return unless has_events?
      event = yield self if block_given?
      event = Event.new(event) unless event.is_a?(Event)

      return unless allow_event?(event)

      trigger_any(event)
      trigger_event(event)
    end
  end
end
