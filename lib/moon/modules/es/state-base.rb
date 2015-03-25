module States
  class Base < ::State
    include StateMiddlewarable
    middleware SchedulerMiddleware
    middleware InputMiddleware
    include Moon::TransitionHost

    attr_reader :updatables
    attr_reader :renderables
    attr_reader :tree

    class CVar
      def initialize
        @data = {}
      end

      def clear
        @data.clear
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end
    end

    @@__cvar__ = CVar.new

    def cvar
      @@__cvar__
    end

    def input
      middleware(InputMiddleware).handle
    end

    def scheduler
      middleware(SchedulerMiddleware).scheduler
    end

    def init
      super
      @updatables = []
      @renderables = []
      @renderer = Moon::RenderContainer.new
      @gui = Moon::RenderContainer.new
      @tree = Moon::Tree.new

      @tree.add @renderer
      @tree.add @gui

      @updatables << @renderer
      @updatables << @gui
      @renderables << @renderer
      @renderables << @gui

      register_default_events
      register_input
    end

    private def register_default_events
      register_default_input_events
    end

    private def register_default_input_events
      input.on :any do |e|
        @renderer.trigger e
        @gui.trigger e
      end

      input.on :press, :left_bracket do
        @scheduler.p_job_table
      end

      input.on :press, :backslash do
        if @debug_shell
          stop_debug_shell
        else
          launch_debug_shell
        end
      end

      input.typing do |e|
        @debug_shell.insert e.char if @debug_shell
      end

      input.on [:press, :repeat], :backspace do
        @debug_shell.erase if @debug_shell
      end

      input.on :press, :enter do
        @debug_shell.exec if @debug_shell
      end

      input.on :press, :up do
        @debug_shell.history_prev if @debug_shell
      end

      input.on :press, :down do
        @debug_shell.history_next if @debug_shell
      end
    end

    private def register_input
      #
    end

    def launch_debug_shell
      @debug_shell = DebugShell.new(FontCache.font('uni0553', 16))
      @debug_shell.position.set(0, 0, 0)
    end

    def stop_debug_shell
      @debug_shell = nil
    end

    def update(delta)
      @updatables.each do |element|
        element.update delta
      end
      update_transitions delta
      super delta
    end

    def render
      @renderables.each do |element|
        element.render
      end
      @debug_shell.render if @debug_shell
      super
    end
  end
end
