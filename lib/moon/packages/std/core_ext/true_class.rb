require 'std/core_ext/object'

class TrueClass
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
