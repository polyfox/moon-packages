module Moon
  class Font
    attr_reader :size

    def initialize(filename, size)
      @filename = filename
      @size = size
    end

    def render(x, y, z, str, color=nil, options={})
      color ||= Vector4.new(1, 1, 1, 1)
      puts "#{self}#render(#{x}, #{y}, #{z}, #{str.dump}, #{color}, #{options})"
    end

    def calc_bounds(str)
      x, y = 0, 0
      str.each_line do |line|
        sz = line.size * @size
        x = sz if x < sz
        y += @size
      end
      return x, y
    end
  end
end
