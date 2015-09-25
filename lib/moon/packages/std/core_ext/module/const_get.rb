class Module
  alias :__const_get__ :const_get

  # const_get resolves namespaces and top level constants!
  #
  # @param [String] path
  # @param [Boolean] inherit
  # @return [Module]
  def const_get(path, *inherit)
    top = self
    paths = path.to_s.split("::")
    if path.to_s.start_with?("::")
      top = Object
      paths.shift
    end
    paths.reduce(top) { |klass, name| klass.__const_get__(name, *inherit) }
  end
end
