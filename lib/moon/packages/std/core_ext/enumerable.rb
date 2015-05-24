module Enumerable
  # Checks if the enum includes all elements from the slice
  #
  # @param [Enumerable] slic
  # @return [Boolean] true if the enum includes all the elements from the slice
  def include_slice?(slic)
    slic.all? { |e| include?(e) }
  end
end
