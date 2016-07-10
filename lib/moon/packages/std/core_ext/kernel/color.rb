module Kernel
  def self.Color(*args)
    case args.size
    when 1, 2
      Moon::Color.hex24(*args)
    when 3, 4
      Moon::Color.new(*args)
    else
      raise ArgumentError, "wrong argument count (expected 1 (int24), 2 (int24, int8), 3 (int[3]) or 4 (int[4]))"
    end
  end
end
