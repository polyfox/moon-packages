module Moon
  class RenderArray < Moon::RenderContainer
    def initialize(size=nil)
      super()
      if size && block_given?
        size.times do |i|
          add(yield i)
        end
      end
    end

    def [](index)
      @elements[index]
    end

    def []=(index, e)
      @elements[index] = e
      e.parent = self
    end

    def select!(&block)
      @elements.select!(&block)
      self
    end

    def reject!(&block)
      @elements.reject!(&block)
      self
    end

    def <<(e)
      add(e)
      self
    end

    def push(e)
      add(e)
      self
    end

    def delete(e)
      remove(e)
    end

    def concat(array)
      array.each { |e| add(e) }; self
    end

    def clear
      @elements.each do |element|
        element.parent = nil
      end
      @elements.clear
    end

    def unshift(e)
      @elements.unshift(e)
      e.parent = self
      self
    end

    def shift
      element = @elements.shift
      element.parent = nil
      element
    end

    def pop
      element = @elements.pop
      element.parent = nil
      element
    end

    def size
      @elements.size
    end

    alias :length :size
  end
end
