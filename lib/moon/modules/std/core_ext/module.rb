class Module #:nodoc:
  alias :__const_get__ :const_get

  def family_attr(name)
    variable_name = "@#{name}"
    define_method(name) do
      var = instance_variable_get(variable_name)
      if var.nil?
        var = []
        instance_variable_set(variable_name, var)
      end
      var
    end

    define_method("all_#{name}") do
      family_call(name).each_with_object([]) do |attrs, ary|
        ary.concat(attrs)
      end
    end
  end

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

  # const_get resolves namespaces and top level constants!
  #
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

  # Creates a new abstract method.
  # A abstract method will fail with a AbstractMethodError when called.
  # It is intended to be rewritten in the subclass before usage.
  #
  # @param [Symbol] method_name
  def abstract(method_name)
    define_method method_name do |*|
      fail AbstractMethodError.new(method_name)
    end
  end

  # Creates a abstract method, similar to attr_writer
  #
  # @param [Symbol] method_name
  def abstract_attr_writer(method_name)
    abstract "#{method_name}="
  end

  # Creates a abstract method, similar to attr_reader
  #
  # @param [Symbol] method_name
  def abstract_attr_reader(method_name)
    abstract method_name
  end

  # Creates a abstract method, similar to attr_accessor
  #
  # @param [Symbol] method_name
  def abstract_attr_accessor(method_name)
    abstract_attr_writer(method_name)
    abstract_attr_reader(method_name)
    method_name
  end

  # Defines a number of constants given a Hash or set of Symbols.
  # When given a Hash, the keys are treated as the const_name.
  # When given a Symbol, the Symbol is treated const_name and the value is index
  # of the symbol in the symbols.
  #
  # @overload enum_const(*symbols)
  #   @param [Symbol] symbols
  # @overload enum_const(options)
  #   @param [Hash<Symbol, Object>]
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
