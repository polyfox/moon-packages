class FalseClass
  include Boolean

  def presence
    nil
  end

  def blank?
    true
  end
end
