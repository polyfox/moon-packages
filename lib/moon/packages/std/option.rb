module Moon
  # Option is a container object for optional values, its main operation is map.
  class Option
    # @!attribute value
    #   @return [Object]
    attr_accessor :value

    # @param [Object] value  initial value
    def initialize(value)
      @value = value
    end

    # If method_name is given, calls the function with the provided args and
    # block and replaces the value with the result.
    # Otherwise, map will take a block and replace the value with the result
    # of the block call.
    #
    # @overload map(method_name, *args, &block)
    #   @param [Symbol] method_name  method to call on value
    # @overload map(&block)
    #   @yieldparam [Object] value  current value
    #   @yieldreturn [Object] new_value  value to replace with
    # @return [Void]
    def map(method_name = nil, *args, &block)
      return if blank?
      if method_name
        @value = @value.send(method_name, *args, &block)
      else
        @value = block.call @value
      end
    end

    # Determines if the value is valid or not, if the value is nil, then it
    # is blank, everything else is none blank.
    #
    # @return [Boolean]
    def blank?
      @value == nil
    end

    # Returns the value unless the blank?
    #
    # @return [Object, nil]
    def presence
      blank? ? nil : @value
    end
  end
end
