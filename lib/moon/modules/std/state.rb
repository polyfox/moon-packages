#
# core/state.rb
#   Base class for all States
class State
  ##
  # @type [Array<State>]
  @states = []

  ##
  # @type [Integer]
  attr_reader :ticks
  ##
  # @type [???]
  attr_reader :engine

  ##
  # @param [???] engine
  def initialize(engine)
    @engine = engine
    @started = false
  end

  ##
  # @return [self]
  def reset
    @ticks = 0
    @started = false
    init
    self
  end

  ##
  # @param [Float] delta
  def step(delta)
    unless @started
      start
      @started = true
    end
    # game logic
    update_step delta
    # rendering
    render_step
    #
    @ticks += 1
  end

  ##
  # @param [Float] delta
  def update_step(delta)
    pre_update delta
    update delta
    post_update delta
  end

  ##
  #
  def render_step
    pre_render
    render
    post_render
  end

  ##
  # Init
  # use this instead to initialize a State
  # @return [Void]
  def init
    #
  end

  ##
  # start
  def start
    #
  end

  ##
  # Gets called when we close the state
  def terminate
    #
  end

  ##
  # Gets called when the state is put on pause and a
  # new state is loaded on top of it
  def pause
    #
  end

  ##
  # Gets called when the state resumes
  def resume
    #
  end

  ##
  # @param [Float] delta
  def pre_update(delta)
    #
  end

  ##
  # Per frame update function, called by moon
  # @param [Float] delta
  # @return [Void]
  def update(delta)
    #
  end

  ##
  # @param [Float] delta
  def post_update(delta)
    #
  end

  ##
  # @return [Void]
  def pre_render
    #
  end

  ##
  # Per frame render function, called by moon
  # called when the state is intended to be rendered to screen
  # @return [Void]
  def render
    #
  end

  ##
  # @return [Void]
  def post_render
    #
  end

  ##
  # Is the State in debug mode?
  def self.debug
    yield
  end

  ##
  # List of all States on the stack
  def self.states
    @states
  end

  ##
  # @return [State]
  def self.current
    @states.last
  end

  ##
  # Moon step entry function
  # @param [Float] delta
  def self.step(delta)
    current.step(delta)
  end

  ##
  # @param [State] state
  def self.change(state)
    last_state = nil
    if !@states.empty?
      @states.last.terminate
      last_state = @states.pop
    end
    debug { puts "[State] CHANGE #{last_state.class} >> #{state}" }
    @states.push state.new(self)
    @states.last.reset
  end

  ##
  #
  def self.pop
    @states.last.terminate
    last_state = @states.pop

    debug { puts "[State] POP #{last_state.class} > #{@states.last.class}" }
    @states.last.resume if !@states.empty?
    debug { puts "--State now empty--" }
  end

  ##
  # @param [State] state
  def self.push(state)
    last_state = @states.last
    @states.last.pause unless @states.empty?
    debug { puts "[State] PUSH #{last_state.class} > #{state}" }
    @states.push state.new(self)
    @states.last.reset
  end
end
