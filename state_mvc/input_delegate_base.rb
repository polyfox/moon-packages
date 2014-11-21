# :nodoc
class State
  ##
  #
  class InputDelegateBase
    ##
    # @param [State::ControllerBase] controller
    def initialize(controller)
      @controller = controller
      init
    end

    ##
    # @abstract
    def init
      #
    end

    ##
    # @param [Moon::Input::Observer, Moon::Eventable] input
    def register(input)
      #
    end
  end
end
