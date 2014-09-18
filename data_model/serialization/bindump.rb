module Moon
  module DataModel
    module Bindump
      ##
      # @return [String] dumped_string
      def bin_dump(depth=0)
        result = []
        each_field_with_value do |key, field, value|
          result << [key, field]
        end
        result.pack("Z")
      end

      ##
      # @param [String] dumped_string
      def bin_load(str, depth=0)
      end
    end
  end
end
