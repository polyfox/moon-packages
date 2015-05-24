class TextInput
  attr_reader :input
  attr_accessor :index
  attr_accessor :mode

  def initialize(target)
    @target = target
    @index = target.string.size
    @mode = :append
    @input = Moon::Input::Observer.new

    @input.typing do |e|
      insert e.char
    end

    @input.on :press, :repeat do |e|
      case e.key
      when :backspace
        erase
      when :insert
        @mode = @mode == :insert ? :append : :insert
      when :left
        cursor_prev
      when :right
        cursor_next
      end
    end
  end

  def index=(inx)
    @index = inx.clamp(0, @target.string.size)
  end

  def cursor_prev
    self.index = @index.pred
    @target.string = @target.string
  end

  def cursor_next
    self.index = @index.succ
    @target.string = @target.string
  end

  def erase
    src = @target.string
    src = (src.slice(0...(@index - 1)) || '') +
          (src.slice(@index..src.size) || '')
    @index = @index.pred.clamp(0, src.size)
    @target.string = src
  end

  def insert(str)
    src = @target.string
    case @mode
    when :append
      src = (src.slice(0, @index) || '') +
        str +
        (src.slice(@index..src.size) || '')
    when :insert
      src[@index] = str
    end
    @index = (@index + str.size).clamp(0, src.size)
    @target.string = src
  end
end

class DebugShell < Moon::RenderContainer
  class Caret < Moon::RenderContext
    def initialize_members
      super
      @index = 0
      @spritesheet = Moon::Spritesheet.new("resources/ui/caret_8x16_ffffffff.png", 8, 16)
      @phase = -1
      @opacity = 1.0
    end

    def w
      @w ||= @spritesheet.cell_w
    end

    def h
      @h ||= @spritesheet.cell_h
    end

    def render_content(x, y, z, options)
      @spritesheet.render(x, y, z, @index, options.merge(opacity: @opacity))
    end

    def update_content(delta)
      @opacity += @phase * delta
      if @opacity < 0 || @opacity > 1
        @phase = -@phase
        @opacity = @opacity.clamp(0, 1)
      end
    end
  end

  class DebugContext
    #
  end

  def init
    super
    font = FontCache.font('uni0553', 16)
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

    on :resize do
      @input_background.w = w
      @input_background.h = h
      @seperator.w = w
      @seperator.h = 1

      @log_text.position.set(4, -4, 0)
      @input_text.position.set(4, h - @input_text.font.size - 8, 0)
      @seperator.position.set(0, @input_text.y, 0)
      @caret.position.set(@input_text.x, @input_text.position.y + 2, 0)
    end

    add @input_background
    add @seperator
    add @input_text
    add @log_text
    add @caret

    self.w = 400
    self.h = 16 * 6

    @text_comp = TextInput.new self
    register_input
  end

  def string
    @input_text.string
  end

  def string=(str)
    @input_text.string = str[0, @text_comp.index]
    @caret.position.x = @input_text.x + @input_text.w + 4
    @input_text.string = str
    @input_text.color.set(1, 1, 1, 1)
  end

  def register_input
    input.on :any do |e|
      @text_comp.input.trigger e
    end

    input.on :press do |e|
      case e.key
      when :enter
        exec
      when :up
        history_prev
      when :down
        history_next
      end
    end
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
