module Moon
  class Texture
    def initialize(filename)
      @filename = filename
      raise unless File.exists?(@filename)
    end

    def width
      32
    end

    def height
      32
    end
  end
end
