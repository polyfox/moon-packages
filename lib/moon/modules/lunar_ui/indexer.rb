module Lunar #:nodoc:
  ##
  # Object for wrapping Array like objects and achieving an Indexable effect
  # without touching the underlaying object.
  class Indexer
    include Moon::Indexable
    include Moon::Eventable

    ##
    # @return [Object]
    attr_accessor :obj

    ##
    # @param [Object] obj
    #   An Object that responds to #[] and #size
    def initialize(obj)
      @obj = obj
      init_eventable
      init_index
    end

    ##
    # Size of the internal object
    # @return [Integer]
    def size
      obj.size
    end

    ##
    # @see Indexable#treat_index
    private def treat_index(new_index)
      new_index % [size, 1].max
    end

    ##
    # Increment index
    def next
      change_index(index + 1)
    end

    ##
    # Decrement index
    def prev
      change_index(index - 1)
    end

    ##
    # :nodoc:
    def refresh
      change_index(index)
    end

    ##
    # Returns the current element in the @obj at @index
    # @return [Object]
    def current_element
      @obj[@index]
    end
  end
end
