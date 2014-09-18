module Moon
  class RenderContainer
    include Containable

    def to_rect
      Rect.new(x, y, width, height)
    end
  end
end
