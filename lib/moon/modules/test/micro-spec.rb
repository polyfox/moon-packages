##
# :nodoc:
module Moon
  ##
  # Basic Spec Framework
  module Test
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
          str, block = *a
          begin
            block.call
            print '.' if realtime
            progress << true
            passed += 1
          rescue => ex
            print 'F' if realtime
            progress << false
            failures << [str, ex.inspect.dup, ex.backtrace.dup]
          end
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
