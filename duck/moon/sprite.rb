module Moon
  class Sprite
    attr_reader :texture
    attr_reader :clip_rect

    def initialize(o)
      if o.is_a?(String)
        @filename = o
        raise unless File.exists?(@filename)
        @texture = Texture.new(@filename)
      else
        raise TypeError, "wrong argument type #{o.class} (expected String)"
      end

      @clip_rect = Rect.new(0, 0, 0, 0)
    end

    def render(x, y, z, index, options={})
      puts "#{self}#render(#{x}, #{y}, #{z}, #{index}, #{options})"
    end
  end
end
