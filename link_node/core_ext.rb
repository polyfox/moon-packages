class Array
  ##
  # @return [LinkNode]
  def to_linked_list
    node = nil
    each do |e|
      if node
        node.append(e.to_link_node)
      else
        node = e.to_link_node
      end
    end
    node
  end
end

class Object
  ##
  # @return [LinkNode]
  def to_link_node
    LinkNode.new(self)
  end
end
