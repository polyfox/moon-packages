class FalseClass
  include Boolean

  # Always returns true.
  #
  # @return [Boolean]
  def blank?
    true
  end
end
