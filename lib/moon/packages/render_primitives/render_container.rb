require 'render_primitives/render_context'

module Moon
  # Inspired by
  # http://dev.chromium.org/developers/design-documents/aura
  #
  # RenderContainers are as there name says, Render Containers, they can contain
  # other RenderContainers or RenderContext objects, they serve the purpose
  # of constructing Render Trees
  class RenderContainer < RenderContext
    include RenderPrimitive::Containable::Parent

    # @return [Array<Moon::RenderContext>]
    attr_reader :elements

    protected def on_child_adopt(child)
      @elements.push child
      refresh_size
    end

    protected def on_child_disown(child)
      @elements.delete child
      refresh_size
    end

    protected def initialize_members
      super
      @elements = []
    end

    #
    protected def initialize_content
      super
      initialize_elements
    end

    # @abstract
    protected def initialize_elements
      #
    end

    #
    protected def initialize_events
      super
      # generic event passing callback
      # this callback will trigger the passed event in the children elements
      # Input::MouseEvent are handled specially, since it requires adjusting
      # the position of the event
      input.on :any do |event|
        @elements.each do |element|
          element.input.trigger event
        end
      end
    end

    def on_resize(*attrs)
      super
      trigger { ResizeEvent.new(self, attrs) }
    end

    # @return [Integer]
    private def compute_w
      x, _, x2, _ = *Moon::Rect.bb_for(@elements)
      x2 - x
    end

    # @return [Integer]
    def w
      @w ||= compute_w
    end

    # @return [Integer]
    private def compute_h
      _, y, _, y2 = *Moon::Rect.bb_for(@elements)
      y2 - y
    end

    # @return [Integer]
    def h
      @h ||= compute_h
    end

    #
    private def refresh_size
      resize nil, nil
    end

    # @yield
    def each(&block)
      @elements.each(&block)
    end

    # @param [Moon::RenderContext] element
    # @return [Moon::RenderContext] element
    def add(element)
      adopt element
      element
    end

    # @param [Moon::RenderContext] element
    # @return [Moon::RenderContext] element
    def remove(element)
      disown element
      element
    end

    #
    def clear_elements
      @elements.clear
      refresh_size
      self
    end

    # @param [Float] delta
    private def update_elements(delta)
      @elements.each { |element| element.update(delta) }
    end

    # @param [Float] delta
    private def update_content(delta)
      update_elements(delta)
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    protected def render_elements(x, y, z)
      @elements.each do |e|
        e.render x, y, z
      end
    end

    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    protected def render_content(x, y, z)
      render_elements(x, y, z)
    end
  end
end
