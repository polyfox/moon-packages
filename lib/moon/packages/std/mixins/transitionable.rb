module Moon
  module Transitionable
    ### mixins
    include TransitionHost

    # @param [String] attribute
    #   @example "color"
    #   @example "position.x"
    # @param [Object] value  target value
    # @param [Numeric] duration  in seconds
    def transition(attribute, value, duration, easer = nil)
      easer ||= Easing::Linear
      src = dotsend(attribute)
      setter = "#{attribute}="
      add_transition(src, value, duration, easer) do |v|
        dotsend(setter, v)
      end
    end

    # Add a keyed transition
    #   A keyed transition will only have 1 active transition per attribute
    #   However multiple transitions can still operate on the attribute if
    #   they where not keyed.
    # @param [String] attribute
    #   @example "color"
    #   @example "position.x"
    # @param [Object] value  target value
    # @param [Numeric] duration  in seconds
    def key_transition(attribute, value, duration)
      @key_transition ||= {}
      if @key_transition.key?(attribute)
        remove_transition(@key_transition[attribute])
      end
      key = attribute
      t = @key_transition[key] = transition(attribute, value, duration)
      t.key = key
      t
    end

    # @param [Array<Transitions>] transitions
    # @return [Void]
    def remove_transitions(transitions)
      if @key_transition
        transitions.each { |t| @key_transition.delete(t.key) if t.key }
      end
      super
    end
  end
end
