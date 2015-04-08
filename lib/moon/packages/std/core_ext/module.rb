class Module
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
