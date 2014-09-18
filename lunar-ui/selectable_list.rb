class SelectableList < Moon::RenderContainer
  include Indexable

  def init_elements
    super
    init_index
    @items = []
  end

  def wrap_index?
    false
  end

  def clamp_index?
    false
  end

  def treat_index(index)
    if wrap_index?
      index % [@items.size, 1].max
    elsif clamp_index?
      [[index, @items.size-1].min, 0].max
    else
      super
    end
  end

  def add_item(item)
    @items << item
  end

  def remove_item(item)
    @items << item
  end

  def current_item
    @items[@index]
  end

  def refresh_item(item, index)
    #
  end

  def refresh_items
    @items.each_with_index do |item, i|
      refresh_item(item, i)
    end
  end

  def refresh
    refresh_items
  end

  def next_item
    self.index = index + 1
  end

  def prev_item
    self.index = index - 1
  end
end
