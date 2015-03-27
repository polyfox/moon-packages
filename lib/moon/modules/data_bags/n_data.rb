module Moon
  # Abstraction for classes that have an Array of 1 type for their main data.
  module NData
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
