require 'std/core_ext/object'

class String
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

  # Returns an indented string
  #
  # @param [Integer] n
  # @return [String]
  def indent(n)
    result = ''
    self.each_line do |line|
      result << (' ' * n) +  line
    end
    result
  end
end
