# :nodoc:
module Moon
  # :nodoc:
  module RenderPrimitive
    ##
    # Visibility control
    module Visibility
      # @return [Boolean]
      attr_accessor :visible

      ##
      # Is this visible?
      #
      # @return [Boolean]
      def visible?
        !!@visible
      end

      ##
      # Is this invisible?
      #
      # @return [Boolean]
      def invisible?
        !@visible
      end

      ##
      # Sets visible to false
      #
      # @return [self]
      def hide
        @visible = false
        self
      end

      ##
      # Sets visible to true
      #
      # @return [self]
      def show
        @visible = true
        self
      end
    end
  end
end
