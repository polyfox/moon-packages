module Moon
  module Test
    module Colorize
      # swiped from colorize.rb
      CONSOLE_COLORS = {
        black:   0, light_black:   60,
        red:     1, light_red:     61,
        green:   2, light_green:   62,
        yellow:  3, light_yellow:  63,
        blue:    4, light_blue:    64,
        magenta: 5, light_magenta: 65,
        cyan:    6, light_cyan:    66,
        white:   7, light_white:   67,
        default: 9
      }

      CONSOLE_MODES = {
        default:   0, # Turn off all attributes
        bold:      1, # Set bold mode
        underline: 4, # Set underline mode
        blink:     5, # Set blink mode
        swap:      7, # Exchange foreground and background colors
        hide:      8  # Hide text (foreground color would be the same as background)
      }

      attr_accessor :colorize_enabled

      def colorize_enabled?
        @colorize_enabled.nil? ? Colorize.enabled : @colorize_enabled
      end

      def colorize(str, fg, bg = :default, mode = :default)
        return str.dup unless colorize_enabled?
        "\033[#{CONSOLE_MODES[mode]};#{CONSOLE_COLORS[fg] + 30};#{CONSOLE_COLORS[bg] + 40}m#{str}\033[0m"
      end

      class << self
        attr_accessor :enabled
      end

      self.enabled = true
    end

    class Colorizer
      include Colorize

      def call(*args)
        colorize(*args)
      end
    end
  end
end
