class Symbol
  # oh look, &:symbol solution
  def call(obj, *args, &block)
    obj.send(self, *args, &block)
  end
end
