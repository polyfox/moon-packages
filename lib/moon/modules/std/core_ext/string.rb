class String
  def blank?
    return true if empty?
    return true if strip.empty?
    false
  end

  def presence
    blank? ? nil : self
  end

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
