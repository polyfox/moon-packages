##
# RenderContext classes are bare bone Renderable objects, they do nothing
# on their own, and serve as a base class for other Renderable objects
module Moon
  class RenderContext
    include Transitionable                               # Moon::Core
    include Eventable                                    # Moon::Core
    include RenderPrimitive::ScreenElement               # RenderPrimitive Core
    include RenderPrimitive::Renderable                  # RenderPrimitive Core
    include RenderPrimitive::Visibility                  # RenderPrimitive Core
    include RenderPrimitive::Containable                 # RenderPrimitive Core
    include RenderPrimitive::Rectangular                 # RenderPrimitive Core

    @@context_id = 0

    attr_reader :id

    def initialize(options={})
      @id = @@context_id += 1

      @width = 0
      @height = 0
      @position = Vector3.new
      @visible  = true
      @parent   = nil

      init_from_options(options)

      init_eventable
      init_content
      init_events
      init
    end

    private def init_from_options(options)
      @position = options.fetch(:position) { Vector3.new(0, 0, 0) }
      @visible  = options.fetch(:visible, true)
    end

    def screen_position
      pos = @position
      elem = self
      while p = elem.parent
        pos += p.position
        elem = p
      end
      pos
    end

    def screen_bounds
      x, y = *screen_position
      Moon::Rect.new(x, y, width, height)
    end

    def render?
      @visible
    end

    private def init_content
      #
    end

    private def init_events
      #
    end

    private def init
      #
    end

    private def update_content(delta)
      #
    end

    def update(delta)
      update_content(delta)
      update_transitions(delta)
    end

    private def render_content(x=0, y=0, z=0, options={})
      #
    end

    private def render_abs(x=0, y=0, z=0, options={})
      px, py, pz = *(@position + [x, y, z])
      render_content(px, py, pz, options)
      super
    end
  end
end
