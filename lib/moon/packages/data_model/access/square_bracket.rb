module Moon
  module DataModel
    class Metal
      ##
      # @param [Symbol] key
      # @return [Object]
      def [](key)
        send key
      end

      ##
      # @param [Symbol] key
      # @param [Object] value
      def []=(key, value)
        send "#{key}=", value
      end
    end
  end
end
