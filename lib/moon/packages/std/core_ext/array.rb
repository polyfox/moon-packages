require 'std/core_ext/object'

class Array
  def blank?
    empty?
  end

  # if the Array only has 1 element, returns it, else returns the entire array.
  #
  # @return [self, Object]
  def singularize
    size > 1 ? self : first
  end

  def sort_by!(&block)
    sort! { |a, b| block.call(a) <=> block.call(b) }
  end unless method_defined?(:sort_by!)

  alias :prepend :unshift
  alias :append :<<
end
