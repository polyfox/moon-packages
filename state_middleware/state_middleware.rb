class MiddlewareManager
  attr_reader :state

  EMPTY = []

  def initialize(state)
    @state = state
    reset
  end

  def reset
    @middlewares = []
    @middleware_registry = {}
    @middleware_hooks = {}
  end

  def refresh
    @middlewares.each do |middleware_klass|
      middleware = middleware_klass.new(state)
      @middleware_registry[middleware_klass] = middleware
      middleware.hooks.each do |hook|
        (@middleware_hooks[hook] ||= []).push(middleware)
      end
    end
  end

  def setup(middlewares)
    reset
    @middlewares = middlewares
    refresh
  end

  def [](klass)
    @middleware_registry[klass]
  end

  def trigger(hook, *args)
    (@middleware_hooks[hook] || EMPTY).each do |middleware|
      middleware.send(hook, *args)
    end
  end
end

module Middlewarable
  module ClassMethods
    def middlewares
      @middlewares ||= []
    end

    def middleware(klass)
      middlewares << klass
    end
  end

  attr_reader :middleware_manager

  def initialize(*args, &block)
    init_middleware
    super(*args, &block)
  end

  private def init_middleware
    @middleware_manager = MiddlewareManager.new(self)
    @middleware_manager.setup(self.class.middlewares)
  end

  def middleware(klass)
    @middleware_manager[klass]
  end
end

module StateMiddlewarable
  include Middlewarable

  # hooks
  def init
    super
    @middleware_manager.trigger :init
  end

  def start
    super
    @middleware_manager.trigger :start
  end

  def pause
    super
    @middleware_manager.trigger :pause
  end

  def unpause
    super
    @middleware_manager.trigger :unpause
  end

  def terminate
    super
    @middleware_manager.trigger :terminate
  end

  def pre_update(delta)
    super
    @middleware_manager.trigger :pre_update, delta
  end

  def update(delta)
    super
    @middleware_manager.trigger :update, delta
  end

  def post_update(delta)
    super
    @middleware_manager.trigger :post_update, delta
  end

  def pre_render
    super
    @middleware_manager.trigger :pre_render
  end

  def render
    super
    @middleware_manager.trigger :render
  end

  def post_render
    super
    @middleware_manager.trigger :post_render
  end

  def self.included(mod)
    mod.extend ClassMethods
  end
end

class BaseMiddleware
  attr_reader :state

  def initialize(state)
    @state = state
  end

  def hooks
    @hooks ||= self.class.hooks
  end

  def self.hooks
    @hooks ||= []
  end

  def self.hook(method_name)
    hooks << method_name
  end
end

class EventHopper
  def initialize(target)
    @target = target
  end

  def trigger(event)
    @target << event
  end
end

class InputMiddleware < BaseMiddleware
  attr_reader :handle

  private def register
    Moon::Input.register(@hopper)
  end

  private def unregister
    Moon::Input.unregister(@hopper)
  end

  hook def init
    @event_stack = []
    @hopper = EventHopper.new(@event_stack)
    @handle = Moon::Input::Observer.new
  end

  hook def start
    register
  end

  hook def pause
    register
  end

  hook def unpause
    unregister
  end

  hook def pre_update(delta)
    until @event_stack.empty?
      ev = @event_stack.shift
      @handle.trigger(ev)
    end
  end
end

class SchedulerMiddleware < BaseMiddleware
  attr_reader :scheduler

  hook def init
    @scheduler = Moon::Scheduler.new
  end

  hook def pre_update(delta)
    @scheduler.update(delta)
  end
end
