class NilClass
  def presence
    nil
  end

  def blank?
    true
  end

  def try(meth=nil, *args, &block)
    #
  end
end
