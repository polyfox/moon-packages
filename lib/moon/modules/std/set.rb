class Set
  def initialize
    @data = {}
  end

  def each(&block)
    @data.keys.each(&block)
  end

  def push(value)
    @data[value] = true
  end
  alias :<< :push

  def delete(value)
    @data.delete(value)
  end
end
