class Hash
  # Has checks if target hash has all the data the other has, this is different
  # from eql? which checks for complete matches.
  #
  # @param [Hash] other
  # @return [Boolean]
  def has?(other)
    other.all? do |pair|
      key, value = *pair
      key?(key) && self[key] == value
    end
  end

  # @param [Object] keys
  # @return [Array<Object>] values from keys
  def values_of(*keys)
    keys.map { |key| self[key] }
  end

  # @param [Object] keys
  # @return [Array<Object>] values from keys
  def fetch_multi(*keys)
    keys.map { |key| fetch(key) }
  end

  # Whether the Hash is blank or not.
  #
  # @return [Boolean]
  def blank?
    empty?
  end

  def exclude(*excluded_keys)
    result = dup
    excluded_keys.each { |key| result.delete(key) }
    result
  end

  def permit(*keys)
    keys.each_with_object({}) { |key, hash| hash[key] = self[key] }
  end

  def symbolize_keys
    each_with_object({}) { |a, hsh| hsh[a[0].to_sym] = a[1] }
  end

  def stringify_keys
    each_with_object({}) { |a, hsh| hsh[a[0].to_s] = a[1] }
  end
end
