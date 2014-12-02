module Moon #:nodoc:
  class Screen #:nodoc:
    ##
    # @return [Moon::Rect]
    def self.rect
      Moon::Rect.new(0, 0, width, height)
    end
  end
end
