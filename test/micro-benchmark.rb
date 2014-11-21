module Moon
  module Test
    module Benchmark
      class Suite
        attr_accessor :name

        def initialize(name)
          @name = name
          @list = []
        end

        def benchmark(name = nil, &block)
          @list << [name, block]
        end

        alias :bm :benchmark

        def bmbm(name = nil, &block)
          benchmark('~> priming: ' + name, &block)
          benchmark('~>    real: ' + name, &block)
        end

        def run_test(name)
          error = -(Time.now - Time.now)
          time_then = Time.now
          yield
          time_now = Time.now
          diff = time_now - time_then
          diffwe = diff - error
          puts '    error: %0.6f    time: %0.6f    actual: %0.6f        %s' % [error, diffwe, diff, name]
          diff
        end

        def run
          puts 'Running Benchmark Suite: ' + name
          @list.each do |testcase|
            name, block = *testcase
            run_test(name, &block)
          end
          puts
        end

        def run_run
          puts 'Running Benchmark Suite (bmbm): ' + name
          puts '~> priming suite'
          @list.each do |testcase|
            name, block = *testcase
            run_test(name, &block)
          end
          puts
          puts '~> real suite'
          @list.each do |testcase|
            name, block = *testcase
            run_test(name, &block)
          end
          puts
        end
      end

      def bench(name, options = {}, &block)
        suite = Suite.new(name)
        yield suite
        if options[:bmbm]
          suite.run_run
        else
          suite.run
        end
        suite
      end
    end
  end
end
