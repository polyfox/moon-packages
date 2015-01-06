module Moon #:nodoc:
  class Rect #:nodoc:
    include RenderPrimitive::Rectangular

    ##
    # @param [String] str
    # @param [Moon::Rect] rect
    def align(str, rect)
      dup.align!(str, rect)
    end

    ##
    # @param [Integer] cx
    # @param [Integer] cy
    def contract(cx, cy = cx)
      cx = cx.to_i
      cy = cy.to_i
      self.class.new(x + cx, y + cy, width - cx * 2, height - cy * 2)
    end
  end
end
