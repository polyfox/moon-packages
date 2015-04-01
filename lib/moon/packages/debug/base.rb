module Debug
  def self.format_depth(str, depth)
    ('  ' * depth) << "#{str}"
  end
end
