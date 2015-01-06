module Moon #:nodoc:
  class Painter2
    attr_reader :target

    def initialize(target)
      @target = target
    end

    # @param [Integer] n
    def fill(n)
      target.map_with_xy { |old_n, x, y| n }
    end

    # @param [Integer] n
    def clear(n = 0)
      fill(n)
    end

    # @overload map_rect(rect)
    #   @param [Moon::Rect, Array[4]<Integer>] rect
    # @overload map_rect(x, y, width, height)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] width
    #   @param [Integer] height
    # @return [self]
    def map_rect(*args)
      x, y, w, h = *Rect.extract(args.size > 1 ? args : args.first)
      h.times do |j|
        w.times do |i|
          target[x + i, y + j] = yield target[x + i, y + j], x, y
        end
      end
      self
    end

    # @param [Integer] x  x-coord
    # @param [Integer] y  y-coord
    # @param [Integer] w  width
    # @param [Integer] h  height
    # @param [Integer] v  value
    # @return [self]
    def fill_rect_xywh(x, y, w, h, v)
      map_rect(x, y, w, h) { v }
    end

    # @overload fill_rect(rect, value)
    #   @param [Moon::Rect, Array<Integer>] rect
    #   @param [Integer] value
    # @overload fill_rect(x, y, width, height, value)
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] width
    #   @param [Integer] height
    #   @param [Integer] value
    # @return [self]
    def fill_rect(*args)
      case args.size
      when 2
        r, n = *args
        fill_rect_xywh(r.x, r.y, r.w, r.h, n)
      when 5
        fill_rect_xywh(*args)
      else
        raise ArgumentError,
              "wrong argument count #{args.size} (expected 2:(rect, value) or 5:(x, y, w, h, value))"
      end
    end
  end
end
