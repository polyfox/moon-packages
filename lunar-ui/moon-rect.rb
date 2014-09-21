module Moon
  class Rect
    include RenderPrimitive::Rectangular

    def contract(cx, cy=cx)
      cx = cx.to_i
      cy = cy.to_i
      Rect.new x + cx, y + cy, width - cx * 2, height - cy * 2
    end

    def inside?(obj)
      x, y = *Vector2.extract(obj)
      x.between?(self.x, self.x2-1) && y.between?(self.y, self.y2-1)
    end

    def clear
      self.x = 0
      self.y = 0
      self.w = 0
      self.h = 0
      self
    end
  end
end
