class Integer
  # Determines if a particular flag or flags have been masked by doing a
  # binary AND and equal
  # If the flag is 0, then the integer is tested for zero instead of flag
  # test
  #
  # @param [Integer] flag
  # @return [Boolean]
  def masked?(flag)
    if flag == 0
      self == 0
    else
      (self & flag) == flag
    end
  end
end
