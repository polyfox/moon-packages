module Moon
  # Mixin to achieve Indexable objects
  module Indexable
    # Event triggered when an Indexable object changes its index,
    # note that this will be triggered EVEN if the index was the same
    class IndexEvent < Moon::Event
      attr_reader :state
      attr_reader :index

      def initialize(state, index)
        @state = state
        @index = index
        super :index
      end
    end

    # @return [Integer]
    attr_reader :index

    private def initialize_index
      @index = 0
    end

    # Modifies the incoming index, use this method for wrapping an index
    # around, or clamping.
    # @param [Integer] index
    # @return [Integer] index
    private def treat_index(index)
      index
    end

    # Callback triggered before a change_index
    private def pre_change_index
      trigger { IndexEvent.new(:pre_index, index) }
    end

    # Callback triggered after a change_index
    private def post_change_index
      trigger { IndexEvent.new(:post_index, index) }
    end

    # @param [Integer] index
    def set_index(index)
      @index = index
    end

    # @param [Integer] index
    def change_index(index)
      pre_change_index
      set_index(treat_index(index))
      post_change_index
    end

    # @param [Integer] index
    def index=(index)
      change_index(index)
    end
  end
end
