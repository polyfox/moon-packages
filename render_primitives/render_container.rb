# Inspired by
# http://dev.chromium.org/developers/design-documents/aura
##
# RenderContainers are as there name says, Render Containers, they can contain
# other RenderContainers or RenderContext objects, they serve the purpose
# of constructing Render Trees
module Moon
  class RenderContainer < RenderContext
    include Enumerable

    attr_reader :elements

    private def init_from_options(options)
      super
      @elements = options.fetch(:elements) { [] }
    end

    private def init_content
      super
      init_elements
    end

    private def init_elements
      #
    end

    private def init_events
      super
      # generic event passing callback
      # this callback will trigger the passed event in the children elements
      # Input::MouseEvent are handled specially, since it requires adjusting
      # the position of the event
      on :any do |event|
        @elements.each do |element|
          element.trigger event
        end
      end

      # click event generation
      on :mousedown do |event|
        @last_mousedown_id = event.id
      end

      on :mouseup do |event|
        trigger :click if @last_mousedown_id == event.id
      end

      # double clicks (click distance was max 500ms)
      on :click do |event|
        now = Moon::Screen.uptime
        if now - @last_click_at < 0.500
          trigger :dblclick
          # reset the distance, so we can't trigger
          #consecutive double clicks with a single click
          @last_click_at = 0.0
        else
          @last_click_at = now
        end
      end

      # dragging support
      @draggable = false

      on :mousedown do |event|
        # bonus: be able to specify a drag rectangle:
        # the area where the user can click to drag
        # the window (useful if we only want it to
        # drag by the titlebar)

        # initiate dragging if @draggable = true
        if @draggable
          @dragging = true

          # store the relative offset of where the mouse
          # was clicked on the object, so we can accurately
          # set the new position
          @offset_x = Moon::Input::Mouse.x - self.x
          @offset_y = Moon::Input::Mouse.y - self.y
        end
      end

      # TODO: implement mousemove
      on :mousemove do |event|
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

      on :mouseup do |event, _|
        # disable dragging
        @dragging = false if @draggable
      end
    end

    def width
      @width ||= begin
        x = 0
        x2 = 0
        @elements.each do |e|
          ex = e.x
          ex2 = ex + e.width
          x = ex if ex < x
          x2 = ex2 if ex2 > x2
        end
        x2 - x
      end
    end

    def width=(width)
      @width = width
      trigger :resize
    end

    def height
      @height ||= begin
        y = 0
        y2 = 0
        @elements.each do |e|
          ey = e.y
          ey2 = ey + e.height
          y = ey if ey < y
          y2 = ey2 if ey2 > y2
        end
        y2 - y
      end
    end

    def height=(height)
      @height = height
      trigger :resize
    end

    def refresh_size
      self.width = nil
      self.height = nil
    end

    def each(&block)
      @elements.each(&block)
    end

    def add(element)
      @elements.push(element)
      element.parent = self

      refresh_size

      element
    end

    def remove(element)
      @elements.delete(element)
      element.parent = nil

      refresh_size

      element
    end

    def clear_elements
      @elements.clear
      refresh_size
    end

    private def update_elements(delta)
      @elements.each { |element| element.update(delta) }
    end

    private def update_content(delta)
      update_elements(delta)
    end

    private def render_elements(x, y, z, options)
      @elements.each do |e|
        e.render x, y, z, options
      end
    end

    private def render_content(x, y, z, options)
      render_elements(x, y, z, options)
      super
    end
  end
end
