##
# :nodoc:
module Moon
  ##
  # :nodoc:
  class Screen
    ##
    # @return [Moon::Rect]
    def self.rect
      Moon::Rect.new(0, 0, width, height)
    end
  end
end
