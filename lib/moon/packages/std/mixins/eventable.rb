require 'std/event'

## Transduce! The "traditional" example

def transduce(xform, f, init, coll)
  coll.reduce(init, &xform.(f))
end

# * is our compose operator, where fn compose(f, g) = g(f(x))
# note that we inverse the order of operators (so it works like piping)
def compose(*args)
  _compose = -> f, g { -> x { f[g[x]] } }
  args.reduce(&_compose)
end

# Common transducers

def mapping(&transform)
  return -> (reduce) {
    return -> (result, input) {
      return reduce.(result, transform.(input))
    }
  }
end

def filtering(&predicate)
  return -> (reduce) {
    return -> (result, input) {
      predicate.(input) ?
        reduce.(result, input) :
        result
    }
  }
end

# Common useful event filters

def key(sym)
  filtering { |event| event.key == sym }
end

def type(sym)
  filtering {|event| event.type == sym }
end

# Complex gate filter

def gate(opener, closer)
  open = false
  return -> (e) {
    open = true if e.type == opener
    open = false if e.type == closer
    return open
  }
end

module Moon
  module Eventable
    def initialize_eventable
      # initialize to a hash of arrays
      @listeners = Hash.new { |h, k| h[k] = [] }
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
    # @param [Symbol] types  event types to listen for
    # @param [Proc] reducer  Reducer to execute on the event stream before the callback.
    # @param [Proc] block  The block we want to execute when we catch the event.
    # @return [#call] the block passed in
    def on(types, reducer = nil, &block)
      reducer ||= -> x { x } # identity
      Array(types).each do |type|
        @listeners[type] << [block, reducer]
      end
      block
    end

    # Shortcut for `on :typing, &block`
    #
    # @param [Proc] reducer  Reducer to execute on the event stream before the callback.
    # @param [Proc] block  The block we want to execute when we catch the event.
    # @return [Proc] block passed in
    def typing(reducer = nil, &block)
      on(:typing, &block)
    end

    # Triggers an Event.
    #
    # @param [Symbol] event
    def trigger(event = nil)
      event = yield self if block_given?
      return unless allow_event?(event)

      # TODO: support :any
      @listeners[event.type].each do |block, reducer|
        # we can do buffering in the future
        transduce(reducer, :<<.to_proc, [], [event]).each do |e|
          block.call(e) # e, self?
        end
      end
    end

    # @!endgroup Registration

    # Does this Eventable allow the event?
    #
    # @param [Moon::Event] event
    # @return [Boolean]
    def allow_event?(event)
      true
    end
  end
end
