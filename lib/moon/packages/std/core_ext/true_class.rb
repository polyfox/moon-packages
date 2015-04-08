require 'std/core_ext/object'
require 'std/core_ext/boolean'

class TrueClass
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
