module Moon
  class StateManager
    # @return [Moon::Engine]
    attr_reader :engine

    # List of all States on the stack
    # @return [Array<State>]
    attr_reader :states

    # @param [Moon::Engine] engine
    def initialize(engine)
      @engine = engine
      @states = []

      setup_input
    end

    def setup_input
      callback = ->(event) { current.input.trigger event if current }
      @engine.input.register(callback)
    end

    # Yields a debug context
    def debug
      yield
    end

    # Is the state manager empty?
    def empty?
      @states.empty?
    end

    # @return [State]
    def current
      @states.last
    end

    # Clears all the states
    def clear
      @states.clear
    end

    # Steps the current state
    #
    # @param [Float] delta
    def step(delta)
      return unless current
      current.step(delta)
    end

    # When a state is spawned, this method is called with the instance
    #
    # @param [State] state
    private def on_spawn(state)
      state.state_manager = self
    end

    # @param [Class<State>] klass
    # @return [State] instance of class
    def spawn(klass)
      state = klass.new @engine
      on_spawn state
      state
    end

    # Terminates and returns the last state, if any
    #
    # @return [State, nil]
    private def eject_last
      unless @states.empty?
        @states.last.revoke
        @states.pop
      end
    end

    # @param [State] state
    def change(state)
      last_state = eject_last
      debug { puts "[#{self.class}] CHANGE #{last_state.class} >> #{state}" }
      @states.push spawn(state)
      @states.last.invoke
    end

    #
    def pop
      @states.last.revoke
      last_state = @states.pop

      debug { puts "[#{self.class}] POP #{last_state.class} > #{@states.last.class}" }
      @states.last.resume if !@states.empty?
    end

    # @param [State] state
    def push(state)
      last_state = @states.last
      @states.last.pause unless @states.empty?
      debug { puts "[#{self.class}] PUSH #{last_state.class} > #{state}" }
      @states.push spawn(state)
      @states.last.invoke
    end
  end
end
