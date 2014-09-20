class Numeric
  def to_json
    JSON.dump(self)
  end
end
