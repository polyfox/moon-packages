module Moon
  module TransitionHost
    # @param [Object] src
    # @param [Object] dest
    # @param [String] duration
    # @return [Transition]
    def create_transition(src, dest, duration, easer = Easing::Linear, &block)
      Transition.new(src, dest, duration, easer, &block)
    end

    # (see #create_transition)
    def add_transition(*args, &block)
      transition = if args.first.is_a?(Transition)
        args.first
      else
        create_transition(*args, &block)
      end
      (@transitions ||= []).push transition
      transition
    end

    # @param [Transition] transition
    # @return [void]
    def remove_transition(transition)
      return unless @transitions
      @transitions.delete transition
    end

    # @param [Array<Transition>] transitions
    # @return [void]
    def remove_transitions(transitions)
      @transitions -= transitions
    end

    # @param [Float] delta
    def update_transitions(delta)
      return unless @transitions
      return if @transitions.empty?
      dead = []
      @transitions.each do |transition|
        transition.update delta
        dead << transition if transition.done?
      end
      unless dead.empty?
        remove_transitions dead
      end
    end

    # Force all transitions to finish.
    # @return [Void]
    def finish_transitions
      return unless @transitions
      @transitions.each(&:finish)
    end
  end
end
