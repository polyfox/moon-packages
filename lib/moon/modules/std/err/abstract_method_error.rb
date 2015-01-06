class AbstractMethodError < NoMethodError
  def initialize(method)
    super "abstract method #{method} was called"
  end
end
