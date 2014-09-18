class Array
  def presence
    empty? ? nil : self
  end

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

  def sort_by!(&block)
    sort! { |a, b| block.call(a) <=> block.call(b) }
  end
end
