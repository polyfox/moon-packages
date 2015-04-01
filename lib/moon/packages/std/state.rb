#
# core/state.rb
#   Base class for all States
class State
  # @!attribute [r] ticks
  #   @return [Integer]
  attr_reader :ticks
  # @!attribute [r] engine
  #   @return [Void]
  attr_reader :engine
  # @!attribute [rw] state_manager
  #   @return [Moon::StateManager]
  attr_accessor :state_manager

  ##
  # @param [Void] engine
  def initialize(engine)
    @engine = engine
    @started = false
    @state_manager = nil
  end

  # Alias for engine.screen
  # @return [Moon::Screen]
  def screen
    @engine.screen
  end

  ##
  # Used when the State is just added to the Stack
  def invoke
    reset
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
end
