##
# :nodoc:
class State
  ##
  # Base class for State Controllers
  class ControllerBase
    # @return [State::ModelBase]
    attr_reader :model
    # @return [State::ViewBase]
    attr_reader :view

    ##
    # @param [State::ModelBase] model
    # @param [State::ViewBase] view
    def initialize(model, view)
      @model, @view = model, view
      init
    end

    ##
    # @abstract
    private def init
      #
    end

    ##
    #
    def start
      @model.start
      @view.start
    end

    ##
    # @param [Float] delta
    # @abstract
    private def update_controller(delta)
      #
    end

    ##
    # @param [Float] delta
    def update(delta)
      update_controller(delta)
      @model.update(delta)
      @view.update(delta)
    end
  end
end
