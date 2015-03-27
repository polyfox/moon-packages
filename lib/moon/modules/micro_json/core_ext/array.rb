class Array #:nodoc:
  # Dumps the Array as a JSON string.
  #
  # @return [String]
  def to_json
    JSON.dump(self)
  end
end
