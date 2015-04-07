class Integer
  def ordinal
    Moon::Inflector.ordinal(self)
  end

  def ordinalize
    Moon::Inflector.ordinalize(self)
  end
end
