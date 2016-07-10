module Moon
  # Utility class for creating Vector4 colors from RGBA8 values
  class Color
    # normalized values
    #
    # @param [Float] r
    # @param [Float] g
    # @param [Float] b
    # @param [Float] a
    # @return [Moon::Vector4]
    def self.new(r, g, b, a = 255)
      Moon::Vector4.new r / 255.0, g / 255.0, b / 255.0, a / 255.0
    end

    # Creates a RGBA color from the given r, g, b, a values
    # @param [Integer] r
    # @param [Integer] g
    # @param [Integer] b
    # @param [Integer] a
    # @return [Moon::Vector4]
    def self.rgba(r, g, b, a)
      new r, g, b, a
    end

    # Creates a RGB color from the given r, g, b values
    #
    # @param [Integer] r
    # @param [Integer] g
    # @param [Integer] b
    # @return [Moon::Vector4]
    def self.rgb(r, g, b)
      rgba r, g, b, 255
    end

    # Creates a monochrome color from the given value +c+
    #
    # @param [Integer] c
    # @return [Moon::Vector4]
    def self.mono(c)
      rgb c, c, c
    end

    # Converts a rgb24 value (usually a HEX) to a Vector4
    # The value should be encoded as 0xRRGGBB
    #
    # @param [Integer] rgb24
    # @return [Moon::Vector4]
    def self.hex24(rgb24, alpha = 255)
      rgba((rgb24 >> 16) & 0xFF, (rgb24 >> 8) & 0xFF, rgb24 & 0xFF, alpha)
    end

    # Converts a rgb32 value (usually a HEX) to a Vector4
    # The value should be encoded as 0xAARRGGBB
    #
    # @param [Integer] rgb32
    # @return [Moon::Vector4]
    def self.hex32(rgb32)
      rgba((rgb24 >> 16) & 0xFF, (rgb24 >> 8) & 0xFF, rgb24 & 0xFF, (rgb32 >> 24) & 0xFF)
    end

    TRANSPARENT = new 0, 0, 0, 0
    WHITE = new 255, 255, 255, 255
    BLACK = new 0, 0, 0, 255
  end
end
