module Moon
  # Mixin for marking objects as active, as to what active means, depends on the
  # object.
  module Activatable
    # @return [Boolean] active  is the object active?
    attr_accessor :active

    # Sets active to true
    #
    # @return [self]
    def activate
      @active = true
      self
    end

    # Sets active to false
    #
    # @return [self]
    def deactivate
      @active = false
      self
    end

    alias :active? :active
  end
end
