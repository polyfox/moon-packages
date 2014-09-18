#
# core/state/state.rb
#   Base class for all States
class State
  ###
  # @type [Array<State>]
  ###
  @states = []

  ###
  # @type [???]
  ###
  attr_reader :ticks
  attr_reader :input
  attr_reader :estack # Event stack
  attr_reader :engine

  ###
  # @param [???] engine
  ###
  def initialize(engine)
    @engine = engine
    @estack = []
    @input = Moon::Input::Observer.new
    @scheduler = Moon::Scheduler.new
  end

  ###
  # Init
  # use this instead to initialize a State
  # @return [void]
  ###
  def init
    @ticks = 0
    puts "[State:#{self.class}] init"
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

  ###
  # Per frame render function, called by moon
  # called when the state is intended to be rendered to screen
  # @return [void]
  ###
  def render
    #
  end

  ###
  # Due threading issues with events from GLFW, they are placed into
  # an array and then processed during the State.update
  ###
  def process_estack
    until @estack.empty?
      ev = @estack.shift
      @input.trigger(ev)
    end
  end

  ###
  # Per frame update function, called by moon
  # @param [float] delta
  # @return [void]
  ###
  def update(delta)
    process_estack
    @scheduler.update(delta)
    @ticks += 1
  end

  ###
  # Is the State in debug mode?
  ###
  def self.debug?
    true
  end

  ###
  # List of all States on the stack
  ###
  def self.states
    @states
  end

  def self.current
    @states.last
  end

  def self.change state
    last_state = nil
    if !@states.empty?
      @states.last.terminate
      last_state = @states.pop
    end
    puts "[State] CHANGE #{last_state.class} >> #{state}" if debug?
    @states.push state.new(self)
    @states.last.init
  end

  def self.pop
    @states.last.terminate
    last_state = @states.pop

    puts "[State] POP #{last_state.class} > #{@states.last.class}" if debug?
    @states.last.resume if !@states.empty?
    puts "--State now empty--" if @states.empty? # TODO
  end

  def self.push state
    last_state = @states.last
    @states.last.pause unless @states.empty?
    puts "[State] PUSH #{last_state.class} > #{state}" if debug?
    @states.push state.new(self)
    @states.last.init
  end
end
