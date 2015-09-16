module Moon
  # Based on https://github.com/timohausmann/quadtree-js
  # ported to moon, mruby
  class Quadtree
    # @return [Moon::Rect]
    attr_reader :bounds
    # @return [Integer]
    attr_reader :max_objects
    # @return [Integer]
    attr_reader :max_levels
    # @return [Integer]
    attr_reader :level
    # @return [Array<Moon::Rectangular>]
    attr_reader :objects
    # @return [Array<Moon::Quadtree>]
    attr_reader :nodes

    # @param [Moon::Rect] bounds
    # @param [Integer] max_objects
    # @param [Integer] max_levels
    def initialize(bounds, max_objects = 10, max_levels = 4, level = 0)
      @bounds = bounds
      @max_objects = max_objects
      @max_levels = max_levels
      @level = level
      @objects = []
      @nodes = []
    end

    # @return [self]
    def split
      next_level = level + 1
      r1, r2, r3, r4 = bounds.split

      nodes[0] = self.class.new(r1, max_objects, max_levels, next_level)
      nodes[1] = self.class.new(r2, max_objects, max_levels, next_level)
      nodes[2] = self.class.new(r3, max_objects, max_levels, next_level)
      nodes[3] = self.class.new(r4, max_objects, max_levels, next_level)

      self
    end

    # @param [Moon::Rect]
    # @return [Integer]
    def get_index(rect)
      vert_mp = bounds.x + bounds.w / 2
      horz_mp = bounds.y + bounds.h / 2

      top_quadrant = rect.y < horz_mp && rect.y + rect.h < horz_mp
      bot_quadrant = rect.y > horz_mp

      if rect.x < vert_mp && rect.x + rect.w < vert_mp
        if top_quadrant
          return 0
        elsif bot_quadrant
          return 2
        end
      elsif rect.x > vert_mp
        if top_quadrant
          return 1
        elsif bot_quadrant
          return 3
        end
      end

      -1
    end

    # @param [Moon::Rect]
    # @return [void]
    def insert(rect)
      unless nodes.empty?
        index = get_index(rect)

        return nodes[index].insert(rect) if index != -1
      end

      objects.push rect

      if objects.size > max_objects && level < max_levels
        split if nodes.empty?

        i = 0
        while i < objects.length
          index = get_index(objects[i])

          if index != -1
            nodes[index].insert(objects.delete_at(i))
          else
            i = i.succ
          end
        end
      end
    end

    # @param [Moon::Rect]
    # @return [Array]
    def retrieve(rect)
      index = get_index(rect)
      result = [].concat(objects)

      unless nodes.empty?
        if index != -1
          result.concat(nodes[index].retrieve(rect))
        else
          nodes.each do |node|
            result.concat(node.retrieve(rect))
          end
        end
      end

      result
    end

    # Clear the Quadtree
    #
    # @return [self]
    def clear
      objects.clear
      nodes.each do |node|
        node.clear if node
      end
      nodes.clear

      self
    end
  end
end
