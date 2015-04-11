require 'test/colorize'

module Moon
  module Test
    class Logger
      # @!attribute [r] c
      #   @return [Colorizer]
      attr_reader :c
      # @!attribute io
      #   @return [#puts, #write]
      attr_accessor :io

      def initialize(io = nil)
        @c = Colorizer.new
        @io = io || STDERR
      end

      def write(*args)
        @io.write(*args)
      end

      def print(*args)
        write(*args)
      end

      def puts(*args)
        @io.puts(*args)
      end

      def prefixed_format(prefix, str, color = :default)
        @c.call(prefix, :light_green) + str
      end

      def note(str)
        puts prefixed_format('NOTE: ', str, :light_green)
      end

      def warn(str)
        puts prefixed_format('WARN: ', str, :light_yellow)
      end

      def error(str)
        puts prefixed_format('ERROR: ', str, :light_red)
      end
    end
  end
end
