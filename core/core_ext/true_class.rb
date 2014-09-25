class TrueClass
  include Boolean

  def presence
    true
  end

  def blank?
    false
  end
end
