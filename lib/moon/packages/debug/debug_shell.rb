class DebugShell < Moon::RenderContainer
  class Caret < Moon::RenderContainer
    def initialize
      super
      @index = 0
      @spritesheet = Moon::Spritesheet.new("resources/ui/caret_8x16_ffffffff.png", 8, 16)
      #@phase = -1
      #@opacity = 255
    end

    def w
      @w ||= @spritesheet.cell_w
    end

    def h
      @h ||= @spritesheet.cell_h
    end

    def render(x=0, y=0, z=0, options={})
      px, py, pz = *(@position + [x, y, z])
      @spritesheet.render(px, py, pz, @index)
      #@spritesheet.render(px, py, pz, @index, options.merge(opacity: @opacity))
      super
    end

    def update(delta)
      super
      #@opacity += 255 * @phase * delta
      #if @opacity < 0 || @opacity > 255
      #  @phase = -@phase
      #  @opacity = [[@opacity, 0].max, 255].min
      #end
    end
  end

  class DebugContext
    #
  end

  def initialize(font)
    super()
    self.w = Moon::Screen.w
    self.h = 16 * 6

    @input_background = Moon::SkinSlice9.new
    @input_background.windowskin = Moon::Spritesheet.new("resources/ui/console_windowskin_dark_16x16.png", 16, 16)

    @seperator = Moon::SkinSlice3.new
    @seperator.windowskin = Moon::Spritesheet.new("resources/ui/line_96x1_ff777777.png", 32, 1)

    @caret = Caret.new

    @history = []
    @history_index = 0
    @contents = []
    @input_text = Moon::Text.new("", font)
    @log_text = Moon::Text.new("", font)
    @log_text.line_h = 1
    @context = DebugContext.new

    @input_text.color = Moon::Vector4.new(1, 1, 1, 1)
    @log_text.color = Moon::Vector4.new(1, 1, 1, 1)

    @input_background.w = w
    @input_background.h = h
    @seperator.w = w
    @seperator.h = 1

    @log_text.position.set(4, 4-8, 0)
    @input_text.position.set(4,5*h/6+4-8, 0)
    @seperator.position.set(0, @input_text.y, 0)
    @caret.position.set(@input_text.x, @input_text.position.y+2, 0)

    add(@input_background)
    add(@seperator)
    add(@input_text)
    add(@log_text)
    add(@caret)
  end

  def add_log(str)
    @contents << str
  end

  def add_history(str)
    @history << str
    @history_index = @history.size
  end

  def history_prev
    @history_index = (@history_index - 1).max(0)
    self.string = @history[@history_index]
  end

  def history_next
    @history_index = (@history_index + 1).min(@history.size)
    self.string = @history[@history_index]
  end

  def cursor_prev
    #
  end

  def cursor_next
    #
  end

  def erase
    self.string = string.chop
  end

  def insert(str)
    self.string += str
  end

  def string
    @input_text.string
  end

  def string=(string)
    @input_text.string = string
    @input_text.color.set(1, 1, 1, 1)
    @caret.position.x = @input_text.x + @input_text.w + 2
  end

  def exec
    return if string.blank?
    add_history string
    begin
      @contents << ">> #{string}"
      result = @context.eval(string).to_s
      add_log result
    rescue Exception => ex
      @contents << ex.message
      @input_text.color.set(1, 0, 0, 1)
    end
    @contents = @contents.last(5)
    @log_text.string = @contents.join("\n")
    self.string = ""
  end
end
