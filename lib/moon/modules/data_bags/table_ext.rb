module Moon
  class Table
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
  end
end
