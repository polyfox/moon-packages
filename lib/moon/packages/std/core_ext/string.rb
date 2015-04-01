class String #:nodoc:
  # Determines if the string is empty, or filled with whitespace.
  #
  # @return [Boolean] whether the string is blank
  def blank?
    return true if empty?
    return true if strip.empty?
    false
  end

  # Returns nil if the string is #blank?, otherwise self
  #
  # @return [self, nil]
  def presence
    blank? ? nil : self
  end

  #
  def demodulize
    path = self.to_s
    if i = path.rindex('::')
      path[(i + 2)..-1]
    else
      path
    end
  end

  def indent(n)
    result = ''
    self.each_line do |line|
      result << (' ' * n) +  line
    end
    result
  end
end
