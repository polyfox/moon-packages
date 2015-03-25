module States
  class Base
    private def register_default_input_events
      input.on Moon::Event do |e|
        @renderer.trigger e
        @gui.trigger e
      end

      input.on Moon::KeyboardEvent, action: :press, key: :left_bracket do
        @scheduler.p_job_table
      end

      input.on Moon::KeyboardEvent, action: :press, key: :backslash do
        if @debug_shell
          stop_debug_shell
        else
          launch_debug_shell
        end
      end

      input.typing do |e|
        @debug_shell.insert e.char if @debug_shell
      end

      [:press, :repeat].each do |e|
        input.on Moon::KeyboardEvent, action: e, key: :backspace do
          @debug_shell.erase if @debug_shell
        end
      end

      input.on Moon::KeyboardEvent, action: :press, key: :enter do
        @debug_shell.exec if @debug_shell
      end

      input.on Moon::KeyboardEvent, action: :press, key: :up do
        @debug_shell.history_prev if @debug_shell
      end

      input.on Moon::KeyboardEvent, action: :press, key: :down do
        @debug_shell.history_next if @debug_shell
      end
    end
  end
end
