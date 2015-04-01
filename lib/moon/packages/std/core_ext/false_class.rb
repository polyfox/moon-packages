class FalseClass #:nodoc:
  include Boolean

  # Always returns true.
  #
  # @return [Boolean]
  def blank?
    true
  end
end
