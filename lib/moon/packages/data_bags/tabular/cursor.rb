module Moon
  module Tabular
    # A Cursor is used to navigate a Table without having to specify the
    # data position each time.
    class Cursor
      # @return [Moon::Tabular]
      attr_reader :src
      # @return [Moon::Vector2]
      attr_accessor :position

      # @param [Moon::Tabular] src
      def initialize(src)
        @position = Vector2.zero
        @src = src
      end

      # Retrieve value at current +position+
      # @overload get
      # @overload get(x, y)
      #   @param [Integer] x
      #   @param [Integer] y
      # @return [Integer]
      def get(*args)
        if args.size > 0
          x, y = *args
          src[position.x + x, position.y + y]
        else
          src[position.x, position.y]
        end
      end
      alias :[] :get

      # Set value at current +position+
      # @overload put(value)
      #   @param [Integer] value  Value to set
      # @overload put(x, y, value)
      #   @param [Integer] x
      #   @param [Integer] y
      #   @param [Integer] value  Value to set
      def put(*args)
        case args.size
        # value
        when 1
          src[position.x, position.y] = args.first
        # x, y, value
        when 3
          x, y, value = *args
          src[position.x + x, position.y + y] = value
        end
      end
      alias :[]= :put
    end
  end
end
