class Object
  # @return [self]
  def presence
    self
  end

  # @return [Boolean]
  def blank?
    !!presence
  end

  # @param [Symbol, String] method_name
  def try(method_name = nil, *args, &block)
    if method_name
      __send__(method_name, *args, &block)
    else
      yield self
    end
  end

  # @param [Array<String, Symbol>] paths
  def paths_send(paths, *args, &block)
    pths = paths.dup
    last = pths.pop
    pths.reduce(self) { |r, meth| r.send(meth) }.send(last, *args, &block)
  end

  #
  # @param [String, Symbol, Array<String, Symbol>] dotsend
  # @eg
  #   obj.dotsend('position.x')
  #   obj.dotsend('map.data.xsize')
  def dotsend(path, *args, &block)
    if path.is_a?(Symbol)
      send(path, *args, &block)
    elsif path.is_a?(Array)
      paths_send(path, *args, &block)
    else
      paths = path.split('.')
      paths_send(paths, *args, &block)
    end
  end
end
