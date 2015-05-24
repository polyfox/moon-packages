class String
  # Dumps the Strings as a JSON string.
  #
  # @return [String]
  def to_json
    JSON.dump self
  end
end
