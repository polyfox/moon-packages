class NilClass #:nodoc:
  # nil should always return a presence of nil.
  #
  # @return [nil]
  def presence
    nil
  end

  # nil is always blank.
  #
  # @return [true]
  def blank?
    true
  end

  # When invoking try, nil does nothing.
  #
  # @param [String, Symbol] method_name
  # @param [Object] args
  # @return [Void]
  def try(method_name = nil, *args, &block)
    #
  end
end
