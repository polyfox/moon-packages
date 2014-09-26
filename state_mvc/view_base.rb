class State
  class ViewBase < Moon::RenderContainer
    attr_accessor :model

    def init
      super
      init_view
    end
  end
end
