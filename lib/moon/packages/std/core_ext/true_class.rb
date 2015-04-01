class TrueClass #:nodoc:
  include Boolean

  # Always returns true.
  #
  # @return [true]
  def presence
    true
  end

  # Always returns false.
  #
  # @return [Boolean]
  def blank?
    false
  end
end
