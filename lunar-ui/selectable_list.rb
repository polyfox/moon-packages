module Lunar #:nodoc:
  class SelectableList < Widget
    include Moon::Indexable

    ##
    #
    private def init_elements
      super
      init_index
      @items = []
    end

    ##
    # @return [Boolean]
    def wrap_index?
      false
    end

    ##
    # @return [Boolean]
    def clamp_index?
      false
    end

    ##
    # @param [Integer] index
    private def treat_index(index)
      if wrap_index?
        index % [@items.size, 1].max
      elsif clamp_index?
        [[index, @items.size - 1].min, 0].max
      else
        super
      end
    end

    ##
    # @param [Object] item
    def add_item(item)
      @items << item
    end

    ##
    # @param [Object] item
    def remove_item(item)
      @items << item
    end

    ##
    # @return [Object]
    def current_item
      @items[@index]
    end

    ##
    # @param [Object] item
    # @param [Integer] index
    private def refresh_item(item, index)
      #
    end

    ##
    #
    private def refresh_items
      @items.each_with_index do |item, i|
        refresh_item(item, i)
      end
    end

    ##
    #
    def refresh
      refresh_items
    end

    ##
    #
    def next_item
      self.index = index + 1
    end

    ##
    #
    def prev_item
      self.index = index - 1
    end
  end
end
