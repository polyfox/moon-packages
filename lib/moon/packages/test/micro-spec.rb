module Moon #:nodoc:
  module Test #:nodoc:
    module Colorize
      # swiped from colorize.rb
      CONSOLE_COLORS = {
          :black   => 0, :light_black    => 60,
          :red     => 1, :light_red      => 61,
          :green   => 2, :light_green    => 62,
          :yellow  => 3, :light_yellow   => 63,
          :blue    => 4, :light_blue     => 64,
          :magenta => 5, :light_magenta  => 65,
          :cyan    => 6, :light_cyan     => 66,
          :white   => 7, :light_white    => 67,
          :default => 9
      }

      CONSOLE_MODES = {
        :default   => 0, # Turn off all attributes
        :bold      => 1, # Set bold mode
        :underline => 4, # Set underline mode
        :blink     => 5, # Set blink mode
        :swap      => 7, # Exchange foreground and background colors
        :hide      => 8  # Hide text (foreground color would be the same as background)
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

    class NullOut
      def write(*args, &block)
      end

      def print(*args, &block)
      end

      def puts(*args, &block)
      end

      def <<(*args, &block)
      end
    end

    class Log
      attr_reader :c
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

    class SpecSuite
      class Stats
        # @return [Moon::Test::Log]
        attr_accessor :log
        # @return [Float]
        attr_accessor :time_diff
        # @return [Array<Array<[String, Exception]>>]
        attr_accessor :fail_stack
        # @return [Array<Boolean>]
        attr_accessor :result_stack
        # @return [Integer]
        attr_accessor :test_count
        # @return [Integer]
        attr_accessor :assertions
        # @return [Integer]
        attr_accessor :assertion_errors
        # @return [Integer]
        attr_accessor :passed

        def initialize
          @log = Log.new
          @fail_stack = []
          @result_stack = []
          @time_diff = 0
          @test_count = 0
          @assertions = 0
          @assertion_errors = 0
          @passed = 0
        end

        def concat(stats)
          @fail_stack.concat(stats.fail_stack)
          @result_stack.concat(stats.result_stack)
          @time_diff += stats.time_diff
          @test_count += stats.test_count
          @assertions += stats.assertions
          @assertion_errors += stats.assertion_errors
          @passed += stats.passed
        end

        def add_pass
          @passed += 1
          @result_stack << true
        end

        def add_failure(obj)
          @result_stack << false
          @fail_stack << obj
        end

        def display_result_stack
          @log.puts
          @result_stack.each do |status|
            @log.print status ? '.' : 'F'
          end
        end

        def display_backtraces
          @log.puts
          @fail_stack.each_with_index do |a, i|
            str, ex = *a
            @log.puts "##{i} #{str}"
            @log.puts ex.inspect
            @log.puts 'Backtrace: >'
            ex.backtrace.each do |l|
              @log.puts "  #{l}"
            end

            # suppress the test_stack
            #if ex.respond_to?(:test_stack)
            #  @log.puts 'Test Stack: >'
            #  ex.test_stack.each do |l|
            #    @log.puts "  #{l}"
            #  end
            #end
            @log.puts
          end
        end

        def display_test_count
          @log.puts
          @log.puts 'Tests: '
          @log.puts '  Total: ' << @test_count.to_s
          @log.puts '     OK: ' << @passed.to_s
          @log.puts '   Fail: ' << (@test_count - @passed).to_s
        end

        def display_assertion_count
          if @assertions > 0
            @log.puts 'Assertions:'
            @log.puts '  Total: ' << @assertions.to_s
            @log.puts '     OK: ' << (@assertions - @assertion_errors).to_s
            @log.puts '   Fail: ' << @assertion_errors.to_s
          end
        end

        def display_time_diff
          @log.puts 'Time: ' << (@time_diff).round(6).to_s[0, 8] << ' seconds'
        end

        def display
          display_result_stack
          display_backtraces
          display_test_count
          display_assertion_count
          display_time_diff
        end
      end

      include Colorize
      include Moon::Test::Assert

      attr_accessor :name
      attr_accessor :log
      attr_accessor :logger
      attr_accessor :tests

      def initialize(name = nil)
        init_assertions
        # spec log
        @log = Log.new
        # debug logger
        @logger = NullOut.new
        @name = name || "#{self.class}"
        @tests = []
        @test_stack = [@tests]
      end

      def describe(obj)
        @logger.puts "#{name}.DESCRIBE: #{obj}"
        @test_stack << []
        yield self
        stack = @test_stack.pop
        stack.map! do |a|
          str, b = *a
          [obj.to_s + " " + str, b]
        end
        @test_stack[-1].concat(stack)
      end

      alias :context :describe

      def describe_top(&block)
        describe(name, &block)
      end

      def it(str, &block)
        @logger.puts "#{name}.IT: #{str}"
        @test_stack[-1] << [str, block]
      end

      def given(str, &block)
        it("given #{str}", &block)
      end

      def spec(str = '', &block)
        it(str, &block)
      end

      def spec_bm(*args, &block)
        spec do
          bench(*args, &block)
        end
      end

      def run_specs(options = {})
        with_assertions = options.fetch(:assertions, true)
        realtime = options.fetch(:realtime_result, true)
        quiet = options.fetch(:quiet, false)

        time_then = Time.now
        passed = 0
        stats = Stats.new
        stats.log = @log
        @tests.each do |a|
          test_name, block = *a
          @log.print test_name
          if (n = 120 - test_name.size - 7) > 0
            @log.print '.' * n
          end

          failure = false
          catch_assertion_errors do |err|
            failure = true
            stats.add_failure [test_name, err]
          end

          begin
            instance_exec(&block)
            if failure
              @log.print colorize('FAILED', :light_red)
            else
              @log.print colorize('PASSED', :light_green)
              stats.add_pass
            end
          rescue AssertError
            # just ignore it
          rescue Exception => ex
            stats.add_failure [test_name, ex]
            @log.puts colorize('KO!', :light_red)
            @log.puts ex.inspect
            @log.puts ex.backtrace.join("\n")
          end
          @log.puts
        end

        time_now = Time.now
        stats.time_diff = (time_now - time_then)
        stats.test_count = @tests.size
        stats.assertions = @assertions
        stats.assertion_errors = @assertion_errors
        stats.display unless quiet
        stats
      end
    end

    # Basic Spec Framework
    module Spec
      attr_accessor :spec_suite

      def init_test_suite
        @spec_suite = SpecSuite.new
      end

      def describe(*a, &b)
        @spec_suite.describe(*a, &b)
      end

      def context(*a, &b)
        @spec_suite.context(*a, &b)
      end

      def it(*a, &b)
        @spec_suite.it(*a, &b)
      end

      def spec(*a, &b)
        @spec_suite.spec(*a, &b)
      end

      def spec_bm(*a, &b)
        @spec_suite.spec_bm(*a, &b)
      end

      def run_specs(*a, &b)
        @spec_suite.run_specs(*a, &b)
      end
    end

    include Spec
  end
end
