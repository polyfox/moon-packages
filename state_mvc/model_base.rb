class State
  class ModelBase < Moon::DataModel::Metal
    ##
    # @abstract
    def start
      # called by a controller
    end

    ##
    # @param [Float] delta
    # @abstract
    private def update_model(delta)
      #
    end

    ##
    # @param [Float] delta
    def update(delta)
      update_model(delta)
    end
  end
end
