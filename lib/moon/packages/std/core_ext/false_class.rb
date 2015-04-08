require 'std/core_ext/object'
require 'std/core_ext/boolean'

class FalseClass
  include Boolean

  # Always returns true.
  #
  # @return [Boolean]
  def blank?
    true
  end
end
