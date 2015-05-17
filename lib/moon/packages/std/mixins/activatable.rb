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

    def active?
      !!active
    end
  end
end
