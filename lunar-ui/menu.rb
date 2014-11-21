module Lunar
  class MenuContainer < SelectableList
    class MenuEvent < Moon::Event
      attr_accessor :state
      attr_accessor :item
      attr_accessor :index

      def initialize(state, item, index)
        @state = state
        @item = item
        @index = index
        super :menu
      end
    end

    Command = Struct.new(:symbol, :title)

    attr_reader :font

    def init_elements
      super
      @font = nil
      @texts = []

      @unselected_color = Moon::Vector4.new(1, 1, 1, 1)
      @selected_color = Moon::Vector4.new(0, 0, 1, 1)
    end

    def clamp_index?
      true
    end

    def font=(font)
      @font = font
      refresh
    end

    def pre_change_index
      @texts[@index].color = @unselected_color
      super
    end

    def post_change_index
      @texts[@index].color = @selected_color
      super
      trigger(MenuEvent.new(:index_changed, current_item, index))
    end

    def add_item(symbol, title)
      super Command.new(symbol, title)
      refresh
    end

    def refresh_item(item, i)
      text = Moon::Text.new(item.title, @font)
      text.position.y = i * (@font.size + 4)
      add(text)
      @texts << text
    end

    def refresh
      clear_elements
      @texts = []
      super
    end

    def cursor_up
      prev_item
    end

    def cursor_down
      next_item
    end

    def cursor_left
      #
    end

    def cursor_right
      #
    end

    def cursor_accept
      trigger(MenuEvent.new(:accept, current_item, index))
    end

    def cursor_cancel
      trigger(MenuEvent.new(:cancel, current_item, index))
    end
  end
end
