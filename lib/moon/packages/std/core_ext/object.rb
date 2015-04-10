class Object
  alias_method :public_send, :send unless method_defined?(:public_send)

  # Attempts to duplicate the object, if the dup fails with a TypeError, self
  # is returned instead.
  #
  # @return [Object, self]
  def safe_dup
    dup
  rescue TypeError
    self
  end

  # Whether the object is valid or not, subclasses should overwrite this
  # method to denote their own `blank?` state.
  #
  # @return [Boolean] is the object blank?
  # @abstract
  def blank?
    !self
  end

  # The opposite of {#blank?}
  #
  # @return [Boolean] is the object present?
  def present?
    !blank?
  end

  # Checks whether the object is blank or not, returns `nil` if the object is
  # {#blank?}, otherwise `self`.
  #
  # @return [self]
  def presence
    blank? ? nil : self
  end

  # Tries to invoke method_name on the object, if the object does not `respond_to?`
  # the method, nil is returned.
  #
  # @param [Symbol, String] method_name
  def try(method_name = nil, *args, &block)
    if respond_to?(method_name)
      public_send(method_name, *args, &block)
    else
      nil
    end
  end

  # Recursively `send`s the symbols to the object, each symbol is sent to the
  # result of the previous send.
  #
  # @param [Array<String, Symbol>] path
  # @api
  #
  # @example
  #   my_map.recursive_send([:map, :data, :xsize])
  private def recursive_send(path, *args, &block)
    path[0, path.size - 1].reduce(self) { |r, meth| r.__send__(meth) }.__send__(path.last, *args, &block)
  end

  #
  # @param [String, Symbol, Array<String, Symbol>] path
  #
  # @example
  #   obj.dotsend('position.x')
  #   obj.dotsend('map.data.xsize')
  def dotsend(path, *args, &block)
    if path.is_a?(Symbol)
      __send__(path, *args, &block)
    elsif path.is_a?(Array)
      recursive_send(path, *args, &block)
    else
      recursive_send(path.split('.'), *args, &block)
    end
  end
end
