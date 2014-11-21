class Module
  alias :__const_get__ :const_get

  ###
  # const_get resolves namespaces and top level constants!
  # @param [String] path
  ###
  def const_get(path)
    top = self
    paths = path.to_s.split("::")
    if path.to_s.start_with?("::")
      top = Object
      paths.shift
    end
    paths.inject(top) { |klass, name| klass.__const_get__(name) }

  ##
  # @param [Symbol] method_name
  def abstract(method_name)
    define_method method_name do |*|
      fail AbstractMethodError.new(method_name)
    end
  end

  ##
  # @param [Symbol] method_name
  def abstract_attr_writer(method_name)
    abstract "#{method_name}="
  end

  ##
  # @param [Symbol] method_name
  def abstract_attr_reader(method_name)
    abstract method_name
  end

  ##
  # @param [Symbol] method_name
  def abstract_attr_accessor(method_name)
    abstract_attr_writer(method_name)
    abstract_attr_reader(method_name)
    method_name
  end

  end
end
