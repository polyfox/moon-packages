class Integer
  def pred
    self - 1
  end

  def round(*a)
    to_f.round(*a)
  end

  def masked?(flag)
    if flag == 0
      self == 0
    else
      (self & flag) == flag
    end
  end
end
