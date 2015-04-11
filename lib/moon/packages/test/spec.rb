require 'test/assert'
require 'test/colorize'
require 'test/spec/stats'

module Moon
  module Test
    class SpecSuite
      include Colorize
      include Moon::Test::Assert

      attr_accessor :name
      attr_accessor :logger
      attr_accessor :debug_logger
      attr_accessor :tests

      def initialize(name = nil)
        init_assertions
        # spec log
        @logger = Logger.new
        # debug debug_logger
        @debug_logger = NullIO::OUT
        @name = name || "#{self.class}"
        @tests = []
        @test_stack = [@tests]
      end

      def describe(obj)
        @debug_logger.puts "#{name}.DESCRIBE: #{obj}"
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
        @debug_logger.puts "#{name}.IT: #{str}"
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
        stats.logger = @logger
        @tests.each do |a|
          test_name, block = *a
          @debug_logger.print test_name
          if (n = 120 - test_name.size - 7) > 0
            @debug_logger.print '.' * n
          end

          failure = false
          catch_assertion_errors do |err|
            failure = true
            stats.add_failure [test_name, err]
          end

          begin
            instance_exec(&block)
            if failure
              @debug_logger.print colorize('FAILED', :light_red)
            else
              @debug_logger.print colorize('PASSED', :light_green)
              stats.add_pass
            end
          rescue AssertError
            # just ignore it
          rescue Exception => ex
            stats.add_failure [test_name, ex]
            @debug_logger.puts colorize('KO!', :light_red)
            @debug_logger.puts ex.inspect
            @debug_logger.puts ex.backtrace.join("\n")
          end
          @debug_logger.puts
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
