require 'std/core_ext/enumerable'

module Moon
  # Module for adding tagging capabilities to Objects, the object in question
  # must implement a tags accessor, which is normally an Array of Strings.
  module Taggable
    # Adds new tags to the object
    #
    # @param [String] tgs
    def tag(*tgs)
      self.tags |= tgs
      self
    end

    # Removes tags from the object
    #
    # @param [String] tgs
    def untag(*tgs)
      self.tags -= tgs
      self
    end

    # Checks if the object includes the tags
    #
    # @param [String] tgs
    def tagged?(*tgs)
      tags.include_slice?(tgs)
    end
  end
end
