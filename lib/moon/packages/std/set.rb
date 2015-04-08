module Moon
  # Basic implementation of Set.
  class Set
    include Enumerable

    # @param [#each] enum
    def initialize(enum = nil, &block)
      @data = {}
      if block_given?
        enum.times { |i| add block.call(i) }
      else
        concat enum if enum
      end
    end

    # Returns an Array from the Set elements.
    #
    # @return [Array<Object>]
    def to_a
      @data.keys.to_a
    end

    # Returns the size of the Set.
    #
    # @return [Integer]
    def size
      @data.size
    end

    # Determines if the Set is empty?
    #
    # @return [Boolean]
    def empty?
      @data.empty?
    end

    # Determins if the Set includes a object
    #
    # @param [Object] obj
    # @return [Boolean]
    def include?(obj)
      @data.key?(obj)
    end

    # Yields each object in the Set.
    #
    # @yieldparam [Object] obj
    def each(&block)
      return to_enum :each unless block_given?
      @data.keys.each(&block)
    end

    # Determines if the Set matches the given object
    #
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      if other.equal?(self)
        true
      elsif other.is_a?(Set) || other.is_a?(Array)
        other.size == size && other.all? { |e| include?(e) }
      else
        false
      end
    end

    # Clear the Set.
    #
    # @return [self]
    def clear
      @data.clear
      self
    end

    # Adds an object to the Set.
    #
    # @param [Object] values
    def add(*values)
      values.each do |e|
        @data[e] = true
      end
      self
    end
    alias :push :add
    alias :<< :add
    alias :unshift :add

    # Removes the object from the set and returns it.
    #
    # @param [Object] value
    # @return [Object]
    def delete(value)
      @data.delete value
      value
    end

    # Appends the +other+ to the current set
    #
    # @param [#each] other
    # @return [self]
    def concat(other)
      other.each do |obj|
        add obj
      end
      self
    end

    # Returns a random object from the Set.
    #
    # @return [Object]
    def sample
      @data.keys.sample
    end

    # Pops an object from the set, may be random.
    #
    # @return [Object]
    def pop
      delete @data.keys.pop
    end

    # Shifts an object from the set, may be random.
    #
    # @return [Object]
    def shift
      delete @data.keys.shift
    end
  end
end
