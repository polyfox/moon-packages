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
  # @type [Moon::Input::Observer]
  attr_reader :input
  ##
  # @type [Array<Moon::Event>]
  attr_reader :estack # Event stack
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
  #
  def reset
    @estack = []
    @ticks = 0
    @input = Moon::Input::Observer.new
    @scheduler = Moon::Scheduler.new
    init
    @started = false
  end

  ##
  # @param [Float] delta
  def step(delta)
    unless @started
      start
      @started = true
    end
    # game logic
    process_events
    pre_update delta
    update delta
    process_jobs delta
    post_update delta
    # rendering
    pre_render
    render
    post_render
    render_gizmos
    render_gui
    #
    @ticks += 1
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
  # Due threading issues with events from GLFW, they are placed into
  # an array and then processed during the State.update
  def process_events
    until @estack.empty?
      ev = @estack.shift
      @input.trigger(ev)
    end
  end

  ##
  # @param [Float] delta
  def process_jobs(delta)
    @scheduler.update(delta)
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
  # @return [Void]
  def render_gizmos
    #
  end

  ##
  # @return [Void]
  def render_gui
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
