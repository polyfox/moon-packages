class Random
  BINARY_DIGITS = %w(0 1)
  OCTAL_DIGITS  = %w(0 1 2 3 4 5 6 7)
  HEX_DIGITS    = %w(0 1 2 3 4 5 6 7 8 9 A B C D E F)
  BASE64_DIGITS = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
                     a b c d e f g h i j k l m n o p q r s t u v w x y z
                     0 1 2 3 4 5 6 7 8 9 + -)

  # Generates a random integer.
  #
  # @param [Integer] size  maximum size of the generate integer
  # @return [Integer]
  def int(size)
    rand(size).to_i
  end

  # Selects a random element from the Array.
  #
  # @param [Array] array
  # @return [Object] random element from the array
  def sample(array)
    return nil if array.empty?
    array[int(array.size)]
  end

  # Generates a random string from the given chars
  #
  # @param [Array<String>] chars  chars to sample from
  # @param [Integer] length  length of the string to generate
  # @return [String] generated string
  def string(chars, length)
    length.times.map { sample(chars) }.join('')
  end

  # Generates a random binary string.
  #
  # @param [Integer] digits  length of the binary string
  # @return [String] string generated
  def binary(digits)
    string(BINARY_DIGITS, digits)
  end

  # Generates a random octal string.
  #
  # @param [Integer] digits  length of the octal string
  # @return [String] string generated
  def octal(digits)
    string(OCTAL_DIGITS, digits)
  end

  # Generates a random hexa-decimal string.
  #
  # @param [Integer] digits  length of the hex string
  # @return [String] string generated
  def hex(digits)
    string(HEX_DIGITS, digits)
  end

  # Generates a random base64 string.
  #
  # @param [Integer] digits  length of the base64 string
  # @return [String] string generated
  def base64(digits)
    string(BASE64_DIGITS, digits)
  end

  # Returns the current settings for Random object.
  #
  # @return [Hash]
  def to_h
    {
      seed: seed
    }
  end

  # Exports the Random as a serializable object
  #
  # @return [Hash<String, Object>]
  def export
    to_h.stringify_keys
  end

  # Loads a serialized Random object
  #
  # @param [Hash<String, Object>] data  data to import
  # @return [Random] instance
  def self.load(data)
    new data["seed"].to_i
  end

  # Returns an instance of the Random class, this is a globally available
  # instance.
  #
  # @return [Random]
  def self.random
    @random ||= new
  end
end
