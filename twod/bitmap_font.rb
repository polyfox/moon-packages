class BitmapFont < Moon::RenderContainer
  attr_reader :string
  def string=(n)
    @string = n != nil ? n.to_s : nil
    refresh_size
  end

  attr_accessor :bold
  attr_accessor :color

  ###
  # Current font cell size is fixed at 8x8
  # @param [String] filename font file name
  # @param [String] string initial ASCII string value
  ###
  def initialize(filename, string="")
    super()
    @color = Vector4.new 1.0, 1.0, 1.0, 1.0
    @cell_size = [8, 8]
    @spritesheet = Cache.bmpfont filename, *@cell_size
    self.string = string
  end

  def refresh_size
    @cached_width = @string.size * @cell_size[0]
    @cached_height = (@string.count("\n") + 1) * @cell_size[1]
  end

  def width
    @cached_width
  end

  def height
    @cached_height
  end

  ###
  # @param [Integer] x
  # @param [Integer] y
  # @param [Integer] z
  ###
  def render(x, y, z)
    if @string
      offset = @bold ? 256 : 0
      row = 0
      col = 0
      px, py, pz = *@position

      @string.bytes.each_with_index do |byte, i|
        if byte.chr == "\n"
          col = 0
          row += 1
          next
        end
        @spritesheet.render px + x + col * @cell_size[0],
                            py + y + row * @cell_size[1],
                            pz + z,
                            byte + offset,
                            color: @color
        col += 1
      end
    end
    super x, y, z
  end
end
