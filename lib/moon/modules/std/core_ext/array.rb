class Array
  def presence
    empty? ? nil : self
  end

  def blank?
    empty?
  end

  def singularize
    size > 1 ? self : first
  end

  def sort_by!(&block)
    sort! { |a, b| block.call(a) <=> block.call(b) }
  end unless method_defined?(:sort_by!)
end
