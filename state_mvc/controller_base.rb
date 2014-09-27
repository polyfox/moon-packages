class State
  class ControllerBase
    attr_reader :model
    attr_reader :view

    def initialize(model, view)
      @model, @view = model, view
      init
    end

    def init
    end

    def start
      @model.start
      @view.start
    end

    private def update_controller(delta)
      #
    end

    def update(delta)
      update_controller(delta)
      @model.update(delta)
      @view.update(delta)
    end
  end
end
