module Moon
  module PaletteParser
    class FormatError < StandardError
    end

    def self.load_palette_hex(colors, bits, format_rgx, format_str)
      bpc = (bits / 3).to_i # bits per channel
      bitmask = 2 ** bpc - 1
      colors.each_with_object({}) do |a, hash|
        key, hex = *a
        matchdata = hex.match(format_rgx)
        raise FormatError, "invalid hex format (#{hex}) expected (#{format_str})" unless matchdata
        value = matchdata[0].to_i(16)
        r = (value >> (bpc * 2)) & bitmask
        g = (value >> bpc) & bitmask
        b = value & bitmask
        hash[key] = Moon::Vector4.new(r/bitmask.to_f, g/bitmask.to_f, b/bitmask.to_f, 1.0)
      end
    end

    def self.load_palette_hex_rgb(colors)
      load_palette_hex(colors, 12, /[0-9a-fA-F]{3}/, "RGB")
    end

    def self.load_palette_hex_rrggbb(colors)
      load_palette_hex(colors, 24, /[0-9a-fA-F]{6}/, "RRGGBB")
    end

    def self.load_palette_array_rgb(colors)
      colors.each_with_object({}) do |a, hash|
        key, ary = *a
        r, g, b = *ary
        hash[key] = Moon::Vector4.new(r/255.0, g/255.0, b/255.0, 1.0)
      end
    end

    def self.load_palette_array_rgba(colors)
      colors.each_with_object({}) do |a, hash|
        key, ary = *a
        r, g, b, a = *ary
        hash[key] = Moon::Vector4.new(r/255.0,g/255.0,b/255.0,a/255.0)
      end
    end

    def self.load_palette_float_array_rgb(colors)
      colors.each_with_object({}) do |a, hash|
        key, ary = *a
        r, g, b = *ary
        hash[key] = Moon::Vector4.new(r,g,b,1.0)
      end
    end

    def self.load_palette_float_array_rgba(colors)
      colors.each_with_object({}) do |a, hash|
        key, ary = *a
        r, g, b, a = *ary
        hash[key] = Moon::Vector4.new(r,g,b,a)
      end
    end

    def self.load_palette(data)
      colors = data.fetch("colors")
      format = data.fetch("format")
      case format
      when "hex.RGB"
        load_palette_hex_rgb colors
      when "hex.RRGGBB"
        load_palette_hex_rrggbb colors
      when "[rgb]"
        load_palette_array_rgb colors
      when "[rgba]"
        load_palette_array_rgba colors
      when "float[rgb]"
        load_palette_float_array_rgb colors
      when "float[rgba]"
        load_palette_float_array_rgba colors
      else
        raise FormatError, "unsupported palette format #{format}"
      end
    end
  end
end
