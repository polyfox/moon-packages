class SelectiveRenderArray < RenderArray
  attr_accessor :index

  def init_elements
    @index = 0
    super
  end

  def render_elements(x, y, z, options)
    if element = @elements[@index]
      element.render(x, y, z, options)
    end
  end
end
