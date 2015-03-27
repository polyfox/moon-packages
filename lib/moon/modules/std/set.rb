# Basic implementation of Set.
class Set
  def initialize
    @data = {}
  end

  # Yields each object in the Set.
  #
  # @yieldparam [Object] obj
  def each(&block)
    return to_enum :each unless block_given?
    @data.keys.each(&block)
  end

  # Adds an object to the Set.
  # @param [Object] value
  def push(value)
    @data[value] = true
    self
  end
  alias :<< :push

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
  # @param [Set, Array, #each] other
  # @return [self]
  def concat(other)
    other.each do |obj|
      push obj
    end
    self
  end

  # Returns a random object from the Set.
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
