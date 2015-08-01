require 'std/mixins/transitionable'
require 'std/mixins/eventable'
require 'std/mixins/taggable'
require 'std/input/observer'
require 'render_primitives/screen_element'
require 'render_primitives/renderable'
require 'render_primitives/visibility'
require 'render_primitives/containable'
require 'render_primitives/rectangular'

# RenderContext classes are bare bone Renderable objects, they do nothing
# on their own, and serve as a base class for other Renderable objects
module Moon
  class RenderContext
    include Transitionable                               # Moon Core
    include Eventable                                    # Moon Core
    include Taggable
    include RenderPrimitive::ScreenElement               # RenderPrimitive Core
    include RenderPrimitive::Renderable                  # RenderPrimitive Core
    include RenderPrimitive::Visibility                  # RenderPrimitive Core
    include RenderPrimitive::Containable                 # RenderPrimitive Core
    include RenderPrimitive::Rectangular                 # RenderPrimitive Core

    # @return [Integer] id counter
    @@context_id = 0

    # @!attribute visible
    #   @return [Boolean] Is this context visible for rendering?
    attr_accessor :visible

    # @!attribute input
    #   @return [Input::Observer] input observer
    attr_accessor :input

    # @!attribute [r] id
    #   @return [Integer] RenderContext id
    attr_reader :id

    # @!attribute tags
    #   @return [Array<String>] tags
    attr_accessor :tags

    # @param [Hash<Symbol, Object>] options
    #   @optional
    def initialize(options = {})
      @id = @@context_id += 1
      pre_initialize
      initialize_eventable # Eventable
      initialize_members   # initialize regular member variables
      initialize_from_options(options) # initialize user options
      initialize_content   # initialize other elements
      initialize_events    # initialize events
      yield self if block_given?
      post_initialize
    end

    # Called before all other initializations
    def pre_initialize
    end

    # Called after all other initializations
    def post_initialize
    end

    private def initialize_members
      @w        = 0
      @h        = 0
      @position = Vector3.new
      @visible  = true
      @parent   = nil
      @tick     = 0.0
      @tags     = []
      @input    = Moon::Input::Observer.new
    end

    # @param [Hash<Symbol, Object>] options
    private def initialize_from_options(options)
      @position = options[:position] || @position
      @visible  = options.fetch(:visible, @visible)
      @w        = options.fetch(:w, @w) # can be nil to invalidate.
      @h        = options.fetch(:h, @h) # can be nil to invalidate.
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
      Moon::Rect.new(x, y, w, h)
    end

    # @return [Boolean]
    def render?
      visible?
    end

    # @abstract
    private def initialize_content
      #
    end

    # @abstract
    private def initialize_events
    end

    def enable_default_events
      input.on :any do |event|
        trigger event
      end

      input.on :mousemove do |event|
        p = event.position
        trigger MouseHoverEvent.new(event, self, p, screen_bounds.contains?(p.x, p.y))
      end

      # click event generation
      input.on :press do |event|
        if event.is_a?(MouseEvent) && event.button == :mouse_left
          #@last_mousedown_id = event.id
          p = event.position
          if screen_bounds.contains?(p.x, p.y)
            @expecting_release = true
          end
        end
      end

      input.on :release do |event|
        if event.is_a?(MouseEvent) && event.button == :mouse_left
          #if @last_mousedown_id == event.id # ids will never match
          if @expecting_release
            @expecting_release = false
            p = event.position
            if screen_bounds.contains?(p.x, p.y)
              trigger ClickEvent.new(self, p, :click)
            end
          end
        end
      end

      # double clicks (click distance was max 500ms)
      on :click do |event|
        now = @tick
        @last_click_at ||= 0.0
        if (now - @last_click_at) < 0.500
          trigger ClickEvent.new(self, event.position, :double_click)
          # reset the distance, so we can't trigger
          #consecutive double clicks with a single click
          @last_click_at = 0.0
        else
          @last_click_at = now
        end
      end

      # dragging support
      @draggable = false

      input.on :press do |event|
        # bonus: be able to specify a drag rectangle:
        # the area where the user can click to drag
        # the window (useful if we only want it to
        # drag by the titlebar)

        # initiate dragging if @draggable = true
        if event.button == :mouse_left && @draggable
          @dragging = true

          # store the relative offset of where the mouse
          # was clicked on the object, so we can accurately
          # set the new position
          @offset_x = Moon::Input::Mouse.x - self.x
          @offset_y = Moon::Input::Mouse.y - self.y
        end
      end

      input.on :mousemove do |event|
        # if draggable, and we are dragging (the mouse is pressed down)

        # update the position, calculated off of
        # the mouse position and the relative offset
        # set on mousedown

        # don't forget to update the widget positions
        # too (refresh_position)
        # NOTE: at the moment the widget position is
        # updated in the update loop each cycle. Might
        # not be the most efficient thing to do.

        if @draggable && @dragging
          self.x = Moon::Input::Mouse.x - @offset_x
          self.y = Moon::Input::Mouse.y - @offset_y
        end
      end

      input.on :release do |event|
        # disable dragging
        @dragging = false if event.button == :mouse_left && @draggable
      end

      input.on [:press, :repeat] do |event|
        if event.is_a?(MouseEvent)
          p = event.position
          trigger MouseFocusedEvent.new(event, self, p, screen_bounds.contains?(p.x, p.y))
        end
      end
    end

    # @param [Moon::Vector3, Numeric, Array] vec3
    # @return [Moon::Vector3]
    def apply_position_modifier(*vec3)
      return @position if vec3.empty?
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
      @tick += delta
    end

    # Overwrite this method to define your own rendering, the coordinates
    # provided are transformed to be the final position on screen.
    #
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    # @api public
    def render_content(x, y, z, options)
      #
    end

    # Renderable callback, this method applies the position_modifiers and
    # finally cals {#render_content}
    #
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    # @api private
    def render_abs(x, y, z, options)
      px, py, pz = *apply_position_modifier(x, y, z)
      render_content(px, py, pz, options)
    end
  end
end
