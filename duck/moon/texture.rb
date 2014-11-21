module Moon
  class Texture
    def initialize(filename)
      @filename = filename
      unless File.exist?(@filename)
        raise ScriptError, "file #{filename} does not exist"
      end
    end

    def width
      32
    end

    def height
      32
    end
  end
end
