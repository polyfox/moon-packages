class Module
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
