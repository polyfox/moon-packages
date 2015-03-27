module Moon #:nodoc:
  class Painter2 #:nodoc:
    # @return [Moon::Tabular]
    attr_reader :target

    # @param [Moon::Table] target
    def initialize(target)
      @target = target
    end

    # @param [Integer] n
    def fill(n)
      target.map_with_xy { |old_n, x, y| n }
    end

    # @param [Integer] n
    def clear(n = nil)
      fill(n || @target.default)
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
          target[x + i, y + j] = yield target[x + i, y + j], i, j
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

    ##
    # @param [Moon::Tabular] table
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] sx
    # @param [Integer] sy
    # @param [Integer] sw
    # @param [Integer] sh
    # @yieldparam [Integer] n
    # @yieldparam [Integer] i
    # @yieldparam [Integer] j
    # @return [self]
    # @api
    private def blit_xywh_with_block(table, x, y, sx, sy, sw, sh)
      map_rect(x, y, sw, sh) do |o, i, j|
        yield(o, i, j) ? table[sx + i, sy + j] : o
      end
    end

    ##
    # @param [Moon::Tabular] table
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] sx
    # @param [Integer] sy
    # @param [Integer] sw
    # @param [Integer] sh
    # @return [self]
    # @api
    private def blit_xywh_without_block(table, x, y, sx, sy, sw, sh)
      map_rect(x, y, sw, sh) do |o, i, j|
        table[sx + i, sy + j]
      end
    end

    ##
    #
    # @overload blit_xywh(table, x, y, sx, sy, sw, sh)
    #   @param [Moon::Table] table
    #   @param [Integer] x
    #   @param [Integer] y
    #   @param [Integer] sx
    #   @param [Integer] sy
    #   @param [Integer] sw
    #   @param [Integer] sh
    # @return [self]
    def blit_xywh(*args, &block)
      if block_given?
        blit_xywh_with_block(*args, &block)
      else
        blit_xywh_without_block(*args)
      end
    end

    ##
    #
    # @param [Moon::Table] table
    # @param [Integer] x
    # @param [Integer] y
    # @param [Moon::Rect] rect
    # @return [self]
    def blit_rect(table, x, y, rect, &block)
      blit_xywh(table, x, y, rect.x, rect.y, rect.w, rect.h, &block)
    end

    ##
    # @overload blit(table, x, y, rect)
    # @overload blit(table, x, y, sx, sy, sw, sh)
    # @return [self]
    def blit(*args, &block)
      case args.size
      when 4
        blit_rect(*args, &block)
      when 7
        blit_xywh(*args, &block)
      else
        raise ArgumentError,
              "wrong argument count #{args.size} (expected 4:(table, x, y, rect) or 7:(table, x, y, sx, sy, sw, sh))"
      end
    end

    ##
    # Replaces all ocurrences of (rmap.key) with (rmap.value)
    #
    # @param [Hash<Integer, Integer>] rmap
    # @return [self]
    def replace_map(rmap)
      target.map_with_xy do |n, x, y|
        rmap[n] || n
      end
      self
    end

    ##
    # Replaces all ocurrences of (a) with (b)
    #
    # @param [Integer] a
    # @param [Integer] b
    # @return [self]
    def replace(a, b)
      replace_map({ a => b })
    end

    ##
    # Replaces all ocurrences that appear in (selection) with the result
    # from the block
    #
    # @yield [Integer]
    # @return [self]
    def replace_select(selection)
      map_with_xy do |n, x, y|
        n = yield n if selection.include?(n)
        n
      end
      self
    end
  end
end
