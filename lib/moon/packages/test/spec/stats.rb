require 'test/logger'

module Moon
  module Test
    class SpecSuite
      class Stats
        # @!attribute logger
        #   @return [Moon::Test::Logger]
        attr_accessor :logger
        # @!attribute time_diff
        #   @return [Float]
        attr_accessor :time_diff
        # @!attribute fail_stack
        #   @return [Array<Array<[String, Exception]>>]
        attr_accessor :fail_stack
        # @!attribute result_stack
        #   @return [Array<Boolean>]
        attr_accessor :result_stack
        # @!attribute test_count
        #   @return [Integer]
        attr_accessor :test_count
        # @!attribute assertions
        #   @return [Integer]
        attr_accessor :assertions
        # @!attribute assertion_errors
        #   @return [Integer]
        attr_accessor :assertion_errors
        # @!attribute passed
        #   @return [Integer]
        attr_accessor :passed

        def initialize
          @logger = Logger.new
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
          @logger.puts
          @result_stack.each do |status|
            @logger.print status ? '.' : 'F'
          end
        end

        def display_backtraces
          @logger.puts
          @fail_stack.each_with_index do |a, i|
            str, ex = *a
            @logger.puts "##{i} #{str}"
            @logger.puts ex.inspect
            @logger.puts 'Backtrace: >'
            ex.backtrace.each do |l|
              @logger.puts "  #{l}"
            end

            # suppress the test_stack
            #if ex.respond_to?(:test_stack)
            #  @logger.puts 'Test Stack: >'
            #  ex.test_stack.each do |l|
            #    @logger.puts "  #{l}"
            #  end
            #end
            @logger.puts
          end
        end

        def display_test_count
          @logger.puts
          @logger.puts 'Tests: '
          @logger.puts '  Total: ' << @test_count.to_s
          @logger.puts '     OK: ' << @passed.to_s
          @logger.puts '   Fail: ' << (@test_count - @passed).to_s
        end

        def display_assertion_count
          if @assertions > 0
            @logger.puts 'Assertions:'
            @logger.puts '  Total: ' << @assertions.to_s
            @logger.puts '     OK: ' << (@assertions - @assertion_errors).to_s
            @logger.puts '   Fail: ' << @assertion_errors.to_s
          end
        end

        def display_time_diff
          @logger.puts 'Time: ' << (@time_diff).round(6).to_s[0, 8] << ' seconds'
        end

        def display
          display_result_stack
          display_backtraces
          display_test_count
          display_assertion_count
          display_time_diff
        end
      end
    end
  end
end
