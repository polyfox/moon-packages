module Containable
  attr_accessor :parent

  def containerize
    container = RenderContainer.new
    container.add(self)
    container
  end

  def align!(*args)
    position.set(to_rect.align(*args).xyz)
  end
end
