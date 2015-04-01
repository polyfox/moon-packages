module Moon
  class Sprite
    def w
      clip_rect ? clip_rect.w : (texture ? texture.w : 0)
    end

    def h
      clip_rect ? clip_rect.h : (texture ? texture.h : 0)
    end
  end
end
