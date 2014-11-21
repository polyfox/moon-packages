module Moon
  class Spritesheet
    attr_reader :cell_width
    attr_reader :cell_height

    def initialize(o, cw, ch)
      @cell_width = cw
      @cell_height = ch
      if o.is_a?(String)
        @filename = o
        raise unless File.exist?(@filename)
        @texture = Texture.new(@filename)
      elsif o.is_a?(Texture)
        @texture = o
      else
        raise TypeError,
              "wrong argument type #{o.class} (expected Texture or String)"
      end
    end

    def render(x, y, z, index, options = {})
      puts "#{self}#render(#{x}, #{y}, #{z}, #{index}, #{options})"
    end
  end
end
