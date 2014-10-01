module Moon
  class Rect
    include RenderPrimitive::Rectangular

    def align(*args, &block)
      dup.align!(*args, &block)
    end

    def contract(cx, cy=cx)
      cx = cx.to_i
      cy = cy.to_i
      self.class.new x + cx, y + cy, width - cx * 2, height - cy * 2
    end
  end
end
