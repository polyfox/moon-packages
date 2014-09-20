class Array
  def presence
    empty? ? nil : self
  end

  def sort_by!(&block)
    sort! { |a, b| block.call(a) <=> block.call(b) }
  end
end
