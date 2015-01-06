module Kernel
  # place this in an exportable script
  # @eg
  #   export do
  #     lambda do |a, b, c|
  #       does_something_with_abc
  #     end
  #   end
  def export
    $exported = yield
  end

  #
  # @param [String] filename
  # @return [Object] exported
  def export_require(filename)
    require filename
    exp, $exported = $exported, nil
    yield exp if block_given?
    exp
  end

  alias :export_load :export_require
end
