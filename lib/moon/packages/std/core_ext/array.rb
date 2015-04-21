require 'std/core_ext/object'

class Array
  # Determines if the object is blank?
  #
  # @return [Boolean]
  def blank?
    empty?
  end

  # If the Array only has 1 element, returns it, else returns the entire array.
  #
  # @return [self, Object]
  def singularize
    size > 1 ? self : first
  end

  # Adds the element to the beginning of the Array.
  #
  # @param [Object] element
  # @return [Void]
  alias :prepend :unshift

  # Adds the element to the end of the Array.
  #
  # @param [Object] element
  # @return [Void]
  alias :append :<<
end
