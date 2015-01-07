##
# :nodoc:
module Moon
  ##
  # Basic Spec Framework
  module Test
    def self.colorize(str, fg, bg = :default, mode = :default)
      # swiped from colorize.rb
      @color_codes ||= {
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
      @modes ={
        :default   => 0, # Turn off all attributes
        :bold      => 1, # Set bold mode
        :underline => 4, # Set underline mode
        :blink     => 5, # Set blink mode
        :swap      => 7, # Exchange foreground and background colors
        :hide      => 8  # Hide text (foreground color would be the same as background)
      }
      "\033[#{@modes[mode]};#{@color_codes[fg] + 30};#{@color_codes[bg] + 40}m#{str}\033[0m"
    end

    module Spec
      def init_test_suite
        @tests = []
        @test_stack = [@tests]
      end

      def describe(obj)
        @test_stack << []
        yield
        stack = @test_stack.pop
        stack.map! do |a|
          str, b = *a
          [obj.to_s + " " + str, b]
        end
        @test_stack[-1].concat(stack)
      end

      alias :context :describe

      def it(str, &block)
        @test_stack[-1] << [str, block]
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
        realtime = options.fetch(:realtime_progress, true)
        time_then = Time.now
        passed = 0
        failures = []
        progress = []
        @tests.each do |a|
          test_name, block = *a
          print format('%-0113s ', test_name)
          begin
            block.call
            #print '.' if realtime
            print Test.colorize('PASSED', :light_green)
            progress << true
            passed += 1
          rescue => ex
            #print 'F' if realtime
            print Test.colorize('FAILED', :light_red)
            progress << false
            failures << [test_name, ex.inspect.dup, ex.backtrace.dup]
          end
          puts
        end
        time_now = Time.now
        unless realtime
          puts
          progress.each do |status|
            print status ? '.' : 'F'
          end
        end
        puts
        failures.each_with_index do |a, i|
          str, inspect, backtrace = *a
          puts "##{i} #{str}"
          puts inspect
          puts backtrace.join("\n").indent(2)
        end
        puts
        puts 'Tests: '
        puts '  Total: ' << @tests.size.to_s
        puts '     OK: ' << passed.to_s
        puts '   Fail: ' << (@tests.size - passed).to_s
        if with_assertions
          puts 'Assertions:'
          puts '  Total: ' << @assertions.to_s
          puts '     OK: ' << (@assertions - @assertions_raised).to_s
          puts '   Fail: ' << @assertions_raised.to_s
        end
        puts 'Time: ' << (time_now - time_then).round(6).to_s[0, 8] << ' seconds'
      end
    end
    include Spec
  end
end
