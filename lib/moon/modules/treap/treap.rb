# based on warzone2100/lib/framework/treap.cpp
class Treap
  attr_reader :key
  attr_reader :priority
  attr_reader :string
  attr_reader :left
  attr_reader :right

  def initialize
    @key = nil
    @priority = nil
    @string = nil
    @left = nil
    @right = nil
  end

  def rotate_right
    tmp = left
    self.left = right
    tmp.right = self
    tmp
  end
  protected :rotate_right

  def rotate_left
    tmp = right
    self.right = left
    tmp.left = self
    tmp
  end
  protected :rotate_left

  def add_node(node)
    if node.key <= key
      left.add_node node
      rotate_right if priority > left.priority
    else
      right.add_node node
      rotate_left if priority > right.priority
    end
  end
  protected :add_node

  def add(key, string)
    node = Treap.new
    node.key = key
    node.string = string
    node.priority = (rand * 0xFFFF).to_i
    add_node node
  end

  def find(skey)
    case skey <=> key
    when  0 then string
    when -1 then left && left.find(key)
    when  1 then right && right.find(key)
    end
  end

  def find_key(sstring)
    return key if sstring == string
    (left && left.find_key(string)) || (right && right.find_key(string))
  end
end
