class Module
  alias :__const_get__ :const_get

  def family_call(method)
    if block_given?
      ancestors.reverse.each do |klass|
        yield klass.send(method) if klass.respond_to?(method)
      end
    else
      Enumerator.new do |yielder|
        ancestors.reverse.each do |klass|
          yielder.yield klass.send(method) if klass.respond_to?(method)
        end
      end
    end
  end

  ##
  # const_get resolves namespaces and top level constants!
  # @param [String] path
  # @return [Module]
  def const_get(path)
    top = self
    paths = path.to_s.split("::")
    if path.to_s.start_with?("::")
      top = Object
      paths.shift
    end
    paths.reduce(top) { |klass, name| klass.__const_get__(name) }
  end

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

  ##
  # @param [Symbol] args
  def enum_const(*args)
    if args.first.is_a?(Hash)
      args.first.each do |key, i|
        const_set(key, i)
      end
    else
      args.each_with_index do |s, i|
        const_set(s, i)
      end
    end
  end
end
