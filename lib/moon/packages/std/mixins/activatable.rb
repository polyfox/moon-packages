module Moon
  # Mixin for marking objects as active, as to what active means, depends on the
  # object.
  module Activatable
    # Sets active to true
    #
    # @return [self]
    def activate
      self.active = true
      self
    end

    # Sets active to false
    #
    # @return [self]
    def deactivate
      self.active = false
      self
    end

    # Is the object active?
    #
    # @return [Boolean]
    def active?
      !!active
    end

    # Is the object inactive?
    #
    # @return [Boolean]
    def inactive?
      !active?
    end
  end
end
