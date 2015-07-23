class Numeric
  # Dumps the Numeric as a JSON string.
  #
  # @return [String]
  def to_json
    JSON.dump self
  end
end
