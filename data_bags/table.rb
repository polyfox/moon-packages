module Moon
  class Table
    private def blit_xywh_with_block(table, x, y, sx, sy, sw, sh)
      sh.times do |fy|
        sw.times do |fx|
          n = table[sx + fx, sy + fy]
          self[x + fx, y + fy] = table[sx + fx, sy + fy] if yield n
        end
      end
      self
    end

    ##
    # @return [self]
    private def blit_xywh_without_block(table, x, y, sx, sy, sw, sh)
      sh.times do |fy|
        sw.times do |fx|
          self[x + fx, y + fy] = table[sx + fx, sy + fy]
        end
      end
      self
    end
    ##
    #
    # @param [Moon::Table] table
    # @param [Integer] x
    # @param [Integer] y
    # @param [Integer] sx
    # @param [Integer] sy
    # @param [Integer] sw
    # @param [Integer] sh
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
    # Set a Table's data from a String and a dictionary
    #
    # @param [String] str
    # @param [Hash<String, Integer>] strmap
    def set_from_strmap(str, strmap)
      str.split("\n").each do |row|
        row.bytes.each_with_index do |c, i|
          set_by_index(i, strmap[c.chr])
        end
      end
      self
    end

    ##
    # Determines if position is inside the Table
    #
    # @overload pos_inside?(x, y)
    # @overload pos_inside?(vec2)
    # @return [Boolean]
    def pos_inside?(*args)
      px, py = *Moon::Vector2.extract(args.size > 1 ? args : args.first)
      px.between?(0, xsize) && py.between?(0, ysize)
    end

    ##
    # Replaces all ocurrences of (rmap.key) with (rmap.value)
    #
    # @param [Hash<Integer, Integer>] rmap
    # @return [self]
    def replace_map(rmap)
      map_with_xy do |n, x, y|
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

    private def rotate_cw
      result = self.class.new(ysize, xsize, default: default)
      ys = ysize - 1
      each_with_xy do |n, x, y|
        result[ys - y, x] = n
      end
      result
    end

    private def rotate_ccw
      result = self.class.new(ysize, xsize, default: default)
      xs = xsize - 1
      each_with_xy do |n, x, y|
        result[y, xs - x] = n
      end
      result
    end

    private def rotate_flip
      result = self.class.new(xsize, ysize, default: default)
      xs, ys = xsize - 1, ysize - 1
      each_with_xy do |n, x, y|
        result[xs - x, ys - y] = n
      end
      result
    end

    ##
    # Rotate the Table data, returns a new Table with the rotated data
    #
    # @param [Integer] angle
    # @return [Table]
    def rotate(angle)
      case (angle % 360)
      when 0   then dup
      when 90  then rotate_cw
      when 180 then rotate_flip
      when 270 then rotate_ccw
      else
        raise RuntimeError, "unsupported rotation angle #{angle}"
      end
    end
  end
end
