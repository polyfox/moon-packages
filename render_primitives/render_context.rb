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

    # @return [Integer] id counter
    @@context_id = 0

    # @return [Integer] RenderContext id
    attr_reader :id

    ##
    # @param [Hash<Symbol, Object>] options
    #   @optional
    def initialize(options = {})
      init_members

      init_from_options(options)

      init_eventable
      init_content
      init_events
      init

      yield self if block_given?
    end

    private def init_members
      @id = @@context_id += 1

      @width     = 0
      @height    = 0
      @position  = Vector3.new
      @visible   = true
      @parent    = nil
    end

    # @param [Hash<Symbol, Object>] options
    private def init_from_options(options)
      @position = options.fetch(:position) { Vector3.new(0, 0, 0) }
      @visible  = options.fetch(:visible, true)
      @width    = options.fetch(:width,   0)
      @height   = options.fetch(:height,  0)
    end

    # @return [Moon::Vector3]
    def screen_position
      pos = apply_position_modifier
      return pos unless parent
      pos + parent.screen_position
    end

    # @return [Moon::Rect]
    def screen_bounds
      x, y = *screen_position
      Moon::Rect.new(x, y, width, height)
    end

    # @return [Boolean]
    def render?
      @visible
    end

    # @abstract
    private def init_content
      #
    end

    # @abstract
    private def init_events
      #
    end

    # @abstract
    private def init
      #
    end

    # @param [Moon::Vector3, Numeric, Array] vec3
    # @return [Moon::Vector3]
    def apply_position_modifier(vec3 = 0)
      @position + vec3
    end

    # @param [Float] delta
    # @abstract
    private def update_content(delta)
      #
    end

    # @param [Float] delta
    def update(delta)
      update_content(delta)
      update_transitions(delta)
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    # @abstract
    private def render_content(x, y, z, options)
      #
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    private def render_abs(x, y, z, options)
      px, py, pz = *apply_position_modifier(Moon::Vector3.new(x, y, z))
      render_content(px, py, pz, options)
      super
    end
  end
end
