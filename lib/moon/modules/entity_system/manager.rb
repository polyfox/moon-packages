module Moon
  module EntitySystem
    class Manager
      def initialize
        @data = {}
      end

      def get(key)
        @data[key]
      end
      alias :[] :get

      def set(key, value)
        @data[key] = value
      end
      alias :[]= :set

      def remove(key)
        @data.delete(key)
      end

      def fetch(key)
        @data.fetch(key)
      end

      def list
        @data.values
      end
    end
  end
end
