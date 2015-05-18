require 'std/core_ext/array'
require 'std/core_ext/symbolic'
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

    # @!group Registration

    # Removes a listener.
    #
    # @param [Boolean] true
    def off(*listeners)
      @listeners.each { |_, ary| ary.delete(listener) }
      true
    end

    # Adds a new event listener.
    #
    # @param [Symbol, Class<Event>] events  events to listen for
    # @param [Proc] block The block we want to execute when we catch the event.
    # @return [Boolean]
    def on(*events, &block)
      events.each { |event| @listener[event] << block }
      @listener[:any] << block
      true
    end

    # Shortcut for `on :typing, &block`
    #
    # @return [Listener]
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

      @listeners[:any].each { |listener| listener.call event }
      @listeners[event.type].each { |listener| listener.call event }
    end
  end
end
