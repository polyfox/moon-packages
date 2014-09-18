module Indexable
  class IndexEvent < Moon::Event
    attr_reader :state
    attr_reader :index

    def initialize(state, index)
      @state = state
      @index = index
      super :index
    end
  end

  attr_reader :index

  def init_index
    @index = 0
  end

  def treat_index(index)
    index
  end

  def pre_change_index
    trigger(IndexEvent.new(:pre_index, index))
  end

  def post_change_index
    trigger(IndexEvent.new(:post_index, index))
  end

  def change_index(index)
    pre_change_index
    @index = treat_index(index)
    post_change_index
  end

  def index=(index)
    change_index(index)
  end
end
