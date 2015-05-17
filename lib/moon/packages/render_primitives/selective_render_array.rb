# :nodoc:
module Moon
  class SelectiveRenderArray < RenderArray
    include Indexable

    ##
    #
    private def init
      super
      initialize_index
    end

    ##
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] z
    # @param [Hash<Symbol, Object>] options
    private def render_elements(x, y, z, options)
      if element = @elements[@index]
        element.render(x, y, z, options)
      end
    end
  end
end
