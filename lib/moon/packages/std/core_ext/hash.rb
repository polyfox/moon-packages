require 'std/core_ext/object'

class Hash
  # Has checks if target hash has all the data the other has, this is different
  # from #eql? which checks for complete matches.
  #
  # @param [Hash] other
  # @return [Boolean]
  #
  # @example
  #   hash = { a: 2, b: 3, c: 4 }
  #   slice1 = { a: 2, b: 3 }
  #   slice2 = { a: 2, c: 5 }
  #   hash.has_slice?(slice1) #=> true
  #   hash.has_slice?(slice2) #=> false
  def has_slice?(other)
    other.all? do |pair|
      key, value = *pair
      key?(key) && (self[key] == value)
    end
  end

  # Creates a new {Hash} from the provided keys, using the values from the
  # {Hash}. Unlike permit, slice will create a Hash with all the keys given.
  #
  # @param [Object] keys  keys to copy from the Hash
  # @return [Hash] hash slice
  def slice(*keys)
    keys.each_with_object({}) { |key, hsh| hsh[key] = self[key] }
  end

  # Similar to #values_of, uses #fetch instead to retrieve the values.
  #
  # @param [Object] keys
  # @return [Array<Object>] values from keys
  #
  # @example
  #   { a: 1, b: 2, c: 3 }.fetch_multi(:a, :b) #=> [1, 2]
  def fetch_multi(*keys)
    keys.map { |key| fetch(key) }
  end

  # Checks if the Hash has any content or not.
  #
  # @return [Boolean]
  #
  # @example
  #   {}.blank?       #=> true
  #   { a: 1 }.blank? #=> false
  def blank?
    empty?
  end

  # Creates a new hash without the provided keys.
  #
  # @param [Object] keys  keys to exclude
  # @return [Hash]
  def exclude(*keys)
    reject { |key, _| keys.include?(key) }
  end

  # Creates a new hash with only provided keys, unlike slice, the result Hash
  # may not have all the keys specified.
  #
  # @param [Object] keys  keys to permit
  # @return [Hash]
  def permit(*keys)
    select { |key, _| keys.include?(key) }
  end

  # Creates a new hash by replacing all its keys with the value from the block.
  #
  # @yieldparam [Object] key  key to replace
  # @yieldreturn [Object] new_key  value to replace key with
  def remap
    each_with_object({}) { |a, hash| hash[yield a[0]] = a[1] }
  end

  # Remaps all keys as {Symbol}s.
  #
  # @return [Hash<Symbol, Object>]
  def symbolize_keys
    remap { |key| key.to_sym }
  end

  # Remaps all keys as {String}s.
  #
  # @return [Hash<String, Object>]
  def stringify_keys
    remap { |key| key.to_s }
  end
end
