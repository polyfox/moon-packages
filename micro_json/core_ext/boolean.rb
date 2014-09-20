module Boolean
  def to_json
    JSON.dump(self)
  end
end
