module Moon
  class StateManager
    # @return [Moon::Engine]
    attr_reader :engine
    # List of all States on the stack
    # @return [Array<State>]
    attr_reader :states

    def initialize(engine)
      @engine = engine
      @states = []
    end

    ##
    # Is the State in debug mode?
    def debug
      yield
    end

    # Is the state manager empty?
    def empty?
      @states.empty?
    end

    ##
    # @return [State]
    def current
      @states.last
    end

    # Clears all the states
    def clear
      @states.clear
    end

    ##
    # Steps the current state
    # @param [Float] delta
    def step(delta)
      current.step(delta)
    end

    # When a state is spawned, this method is called with the instance
    #
    # @param [State] state
    private def on_spawn(state)
    end

    # @param [Class<State>] klass
    # @return [State] instance of class
    def spawn(klass)
      state = klass.new @engine
      on_spawn state
      state
    end

    # terminates and returns the last state, if any
    #
    # @return [State, nil]
    private def eject_last
      if !@states.empty?
        @states.last.terminate
        @states.pop
      end
    end

    ##
    # @param [State] state
    def change(state)
      last_state = eject_last
      debug { puts "[#{self.class}] CHANGE #{last_state.class} >> #{state}" }
      @states.push spawn(state)
      @states.last.invoke
    end

    ##
    #
    def pop
      @states.last.terminate
      last_state = @states.pop

      debug { puts "[#{self.class}] POP #{last_state.class} > #{@states.last.class}" }
      @states.last.resume if !@states.empty?
      debug { puts "--#{self.class} now empty--" }
    end

    ##
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
