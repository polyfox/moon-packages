# An error raised from an abstract method call
# (see Moon::Abstract#abstract)
class AbstractMethodError < NoMethodError
  # @param [Symbol, String] method  name of the method
  def initialize(method)
    super "abstract method #{method} was called"
  end
end
