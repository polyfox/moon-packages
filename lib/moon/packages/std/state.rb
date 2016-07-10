# Base class for all States
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

  # @param [Void] engine
  def initialize(engine)
    @engine = engine
    @started = false
    @state_manager = nil
    post_initialize
  end

  # Callback after a State has been initialized
  def post_initialize
    #
  end

  # Alias for engine.screen
  #
  # @return [Moon::Screen]
  def screen
    @engine.screen
  end

  # Called when the State is added to a stack, commonly by a state_manager
  def invoke
    reset
  end

  # Called when the State is to be removed from the stack
  def revoke
    if @inited
      terminate
      @inited = false
    end
  end

  # @return [self]
  def reset
    @ticks = 0
    @started = false
    init
    @inited = true
    self
  end

  # @param [Float] delta
  def step(delta)
    unless @started
      start
      @started = true
    end
    # game logic
    update delta
    #
    @ticks += 1
  end

  # Init
  # use this instead to initialize a State
  # @return [Void]
  def init
    #
  end

  # start
  def start
    #
  end

  # Gets called when we close the state
  def terminate
    #
  end

  # Gets called when the state is put on pause and a
  # new state is loaded on top of it
  def pause
    #
  end

  # Gets called when the state resumes
  def resume
    #
  end

  # Per frame update function, called by moon
  #
  # @param [Float] delta
  # @return [Void]
  def update(delta)
    #
  end
end
