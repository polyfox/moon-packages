module Moon
  class RenderArray < Moon::RenderContainer
    def initialize(size = nil)
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
      rejected = @elements.select!(&block)
      rejected.each(&:disown)
      self
    end

    def reject!(&block)
      rejected = @elements.reject!(&block)
      rejected.each(&:disown)
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
      @elements.each(&:disown)
      @elements.clear
    end

    def unshift(e)
      @elements.unshift(e)
      e.parent = self
      self
    end

    def shift
      element = @elements.shift
      element.disown
      element
    end

    def pop
      element = @elements.pop
      element.disown
      element
    end

    def size
      @elements.size
    end

    alias :length :size
  end
end
