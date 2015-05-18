require 'std/event'

module Moon
  module Eventable
    def initialize_eventable
      # initialize to a hash of arrays
      @listeners = Hash.new { |h, k| h[k] = [] }
    end

    # @return [Boolean] are there any active event listeners?
    def has_events?
      !@listeners.empty?
    end

    # Yields each listener of given type, defaults to :any
    #
    # @param [Symbol] type
    # @yieldparam [Symbol] type
    # @yieldparam [#call] block
    def each_listener(*types, &block)
      return to_enum(:each_listener, *types) unless block_given?
      if types.empty?
        @listeners.each { |key, ary| ary.each { |cb| block.call(key, cb) } }
      else
        types.each do |type|
          @listeners[type].each { |cb| block.call(type, cb) }
        end
      end
    end

    # @!group Registration

    # Removes a listener.
    #
    # @param [Array<Object>] listeners
    def off(*listeners)
      @listeners.each do |_, ary|
        listeners.each { |cb| ary.delete(cb) }
      end
    end

    # Adds a new event listener.
    #
    # @param [Symbol] events  events to listen for
    # @param [Proc] block  The block we want to execute when we catch the event.
    # @return [#call] the block passed in
    def on(*events, &block)
      events.each { |event| @listeners[event.to_sym] << block }
      block
    end

    # Shortcut for `on :typing, &block`
    #
    # @return [Proc] block passed in
    def typing(&block)
      on(:typing, &block)
    end
    # @!endgroup Registration

    # Does this Eventable allow the event?
    #
    # @param [Moon::Event] event
    # @return [Boolean]
    def allow_event?(event)
      true
    end

    # Triggers an Event.
    #
    # @param [Symbol] event
    def trigger(event = nil)
      return unless has_events?
      event = yield self if block_given?

      return unless allow_event?(event)

      each_listener(:any, event.type) { |_, listener| listener.call event }
    end
  end
end
