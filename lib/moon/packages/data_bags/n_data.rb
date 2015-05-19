module Moon
  # Abstraction for classes that have an Array of 1 type for their main data.
  module NData
    private def post_import
      recalculate_size
    end

    # due to the lazy initialization, the data may need to be padded before
    # export.
    private def pre_export
      if @data.size != @size
        index = @data.size
        @data[@size - 1] ||= @default # resize
        index.upto(@size) do |i|
          @data[i] ||= @default
        end
      end
    end

    # Initializes the internal data
    private def create_data
      recalculate_size
      @data = []
      #@data = Array.new(@size, @default)
    end

    # write_data is a variation of change_data, it validates the size of the
    # data set and then replaces the current data with the given
    #
    # @param [Array<Integer>] data_p
    # @api
    def write_data(data_p)
      if data_p.size > @size
        raise Moon::OverflowError, 'given dataset is larger than internal'
      elsif data_p.size < @size
        raise Moon::UnderflowError, 'given dataset is smaller than internal'
      end
      @data.replace(data_p)
    end
  end
end
