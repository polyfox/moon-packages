require 'std/mixins/transitionable'
require 'std/mixins/eventable'
require 'std/mixins/taggable'
require 'std/input/observer'
require 'render_primitives/screen_element'
require 'render_primitives/renderable'
require 'render_primitives/visibility'
require 'render_primitives/containable'
require 'render_primitives/rectangular'

module Moon
  # RenderContext classes are bare bone Renderable objects, they do nothing
  # on their own, and serve as a base class for other Renderable objects
  class RenderContext
    include Transitionable                               # Moon Core
    include Eventable                                    # Moon Core
    include Taggable
    include RenderPrimitive::ScreenElement               # RenderPrimitive Core
    include RenderPrimitive::Renderable                  # RenderPrimitive Core
    include RenderPrimitive::Visibility                  # RenderPrimitive Core
    include RenderPrimitive::Containable                 # RenderPrimitive Core
    include RenderPrimitive::Rectangular                 # RenderPrimitive Core

    # Global context incremented id, do not touch this, it used by the
    # contexts on initialize for their id
    #
    # @return [Integer] id counter
    # @api private
    @@context_id = 0

    # Controls whether or not the context is rendered,
    # (see Moon::RenderPrimitive::Visiblity) for more info
    # @!attribute visible
    #   @return [Boolean] Is this context visible for rendering?
    attr_accessor :visible

    # Push input events to this observer instead of directly on the context
    # @!attribute input
    #   @return [Input::Observer] input observer
    attr_accessor :input

    # A unique id for the context
    # @!attribute [r] id
    #   @return [Integer] id
    attr_reader :id

    # A set of tags for identifying or labelling the context, see the
    # (see Moon::Taggable) for more info
    #
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
    # Use this method pre tune your object, however most cases you will
    # use the other initializers and post_initialize
    #
    # @abstract
    protected def pre_initialize
    end

    # Called after all other initializations
    # Use this to finalize the the context, such as generating buffers or
    # resizing the context
    #
    # @abstract
    protected def post_initialize
    end

    # Extend this method to initialize data objects, such as integers, vectors
    # and so forth, if you need to initailzie renderables use
    # {#initialize_content} instead
    protected def initialize_members
      @w        = 0
      @h        = 0
      @position = Vector3.new
      @visible  = true
      @parent   = nil
      @tick     = 0.0
      @tags     = []
      @input    = Moon::Input::Observer.new
    end

    # Extend this method to initialize your object from given options
    #
    # @param [Hash<Symbol, Object>] options
    # @option options [Moon::Vector3] :position
    # @option options [Boolean] :visible
    # @option options [Integer] :w
    # @option options [Integer] :h
    protected def initialize_from_options(options)
      @position = options[:position] || @position
      @visible  = options.fetch(:visible, @visible)
      @w        = options.fetch(:w, @w) # can be nil to invalidate.
      @h        = options.fetch(:h, @h) # can be nil to invalidate.
    end

    # Returns the absolute position that this object would appear on the
    # screen, assuming its top most parent is renderered at 0, 0, 0
    #
    # @return [Moon::Vector3]
    def screen_position
      pos = apply_position_modifier
      return pos unless parent
      pos + parent.screen_position
    end

    # Returns the absolute rect this object would appear in, the position is
    # taken from {#screen_position}
    #
    # @return [Moon::Rect]
    def screen_bounds
      x, y = *screen_position
      Moon::Rect.new(x, y, w, h)
    end

    # Should the context be renderered?
    #
    # @return [Boolean]
    def render?
      visible?
    end

    # Overwrite this method to initialize other renderable objects, if you need
    # to initailze some data, use {#initialize_members} instead, be sure to
    # call its super method.
    #
    # @abstract
    protected def initialize_content
      #
    end

    # Overwrite this method to initialize event handlers
    #
    # @abstract
    protected def initialize_events
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

    # Overwrite this method to define your own updating routine
    #
    # @param [Float] delta
    # @abstract
    protected def update_content(delta)
      #
    end

    # Method called every frame, updates the internals
    #
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
    protected def render_content(x, y, z, options)
      #
    end

    # Renderable callback, this method applies the position_modifiers and
    # finally calls {#render_content}, do not mess with this.
    #
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    # @api protected
    protected def render_abs(x, y, z, options)
      px, py, pz = *apply_position_modifier(x, y, z)
      render_content(px, py, pz, options)
    end
  end
end
