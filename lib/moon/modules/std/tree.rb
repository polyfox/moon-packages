module Moon #:nodoc
  # tree
  class Tree
    include Enumerable

    def initialize
      @children = []
    end

    def each(&block)
      @children.each(&block)
    end

    def set(index, child)
      @children[index] = child
    end

    def get(index)
      @children[index]
    end

    def insert(index, child)
      @children.insert(index, child)
    end

    def delete(child)
      @children.delete(child)
    end

    def remove(index)
      @children.delete_at(index)
    end

    def size
      @children.size
    end

    def max
      0xFFFF
    end
  end
end
