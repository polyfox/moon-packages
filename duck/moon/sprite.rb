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

    def render(x, y, z, options={})
      puts "#{self}#render(#{x}, #{y}, #{z}, #{options})"
    end

    def clip_rect=(rect)
      @clip_rect = rect
    end
  end
end
