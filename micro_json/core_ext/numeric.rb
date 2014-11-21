class Numeric
  ##
  # @return [String]
  def to_json
    JSON.dump(self)
  end
end
