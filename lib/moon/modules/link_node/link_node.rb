##
# Wrapper object for creating linked lists
class LinkNode
  include Enumerable

  # @return [Object]
  attr_accessor :value
  # @return [LinkNode]
  attr_accessor :nxt
  # @return [LinkNode]
  attr_accessor :prv

  ##
  # @param [Object] value
  def initialize(value)
    @value = value
    @nxt = nil
    @prv = nil
  end

  ##
  #
  def each(&block)
    yield self
    @nxt.each(&block) if @nxt
  end

  ##
  # Remove and return the first node in this list
  #
  # @return [LinkNode]
  def shift
    node = first
    first = node.nxt
    first.prv = nil
    node.nxt = nil
    node
  end

  ##
  # Remove and return the last node in this list
  #
  # @return [LinkNode]
  def pop
    node = last
    last = node.prv
    last.nxt = nil
    node.prv = nil
    node
  end

  ##
  # Place the node before the parent node of this node and append this to
  # the given node's tail
  #
  # @param [LinkNode] node
  # @return [LinkNode]
  def insert(node)
    @prv.nxt = node.first if @prv
    node.first.prv = @prv
    node.last.nxt = self
    node
  end

  ##
  # Remove this node from the list
  #
  # @return [LinkNode]
  def delete
    @nxt.prv = @prv if @nxt
    @prv.nxt = @nxt if @prv
    self
  end

  ##
  # Place node at the end of the list
  #
  # @return [LinkNode]
  def append(node)
    nxt = @nxt
    top = self
    while nxt
      top = nxt
      nxt = nxt.nxt
    end
    node = node.first
    top.nxt = node
    node.prv = top
    node
  end

  ##
  # Place node at the start of the list
  #
  # @return [LinkNode]
  def prepend(node)
    prv = @prv
    top = self
    while prv
      top = prv
      prv = prv.prv
    end
    node = node.last
    top.prv = node
    node.nxt = top
    node
  end

  ##
  # Retrieve the last node
  #
  # @return [LinkNode]
  def last
    if @nxt
      @nxt.last
    else
      self
    end
  end

  ##
  # Retrieve the first node
  #
  # @return [LinkNode]
  def first
    if @prv
      @prv.first
    else
      self
    end
  end

  ##
  # Retrieve the next node
  #
  # @return [LinkNode]
  def succ
    @nxt || self
  end

  ##
  # Retrieve the previous node
  #
  # @return [LinkNode]
  def pred
    @prv || self
  end

  ##
  # Convert this list to a looped list
  #
  # @return [LinkNode]
  def loop!
    f, l = first, last
    first.prv = l
    last.nxt = f
  end

  ##
  # Detach the next node from this
  # @return [self]
  def snap
    @nxt.prv = nil if @nxt
    @nxt = nil
    self
  end

  ##
  # Detach from the previous element leaving only the next nodes from this
  # @return [self]
  def detach
    @prv.next = nil if @prv
    @prv = nil
    self
  end
end
