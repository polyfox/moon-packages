class Indexer
  include Indexable
  include Moon::Eventable

  attr_accessor :obj

  def initialize(obj)
    @obj = obj
    init_eventable
    init_index
  end

  def size
    obj.size
  end

  def treat_index(new_index)
    new_index % [size, 1].max
  end

  def next
    change_index(index + 1)
  end

  def prev
    change_index(index - 1)
  end

  def refresh
    change_index(index)
  end

  def current_element
    @obj[@index]
  end
end
