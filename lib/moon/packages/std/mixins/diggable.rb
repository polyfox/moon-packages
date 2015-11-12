module Moon
  module Diggable
    # Backported from ruby 2.3.0 for moon
    #
    # @param [Array<Object>]
    # @return [Object, nil]
    def dig(*args)
      raise ArgumentError, "expected 1+ arguments" if args.empty?

      sym = args.shift
      obj = self[sym]
      return obj if args.empty?
      return nil unless obj.respond_to?(:dig)
      obj.dig(*args)
    end
  end
end
