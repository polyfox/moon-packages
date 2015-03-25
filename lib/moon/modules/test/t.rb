module Moon
  module Test
    class TestAbort < RuntimeError
    end

    class TestFail < TestAbort
    end

    class TestSkip < TestAbort
    end

    # http://golang.org/pkg/testing/#T
    class T
      attr_accessor :logger

      def initialize
        @logger = nil
        @failed = false
        @skipped = false
      end

      def fail
        @failed = true
      end

      def fail_now
        fail
        raise TestFail
      end

      def failed?
        @failed
      end

      def logf(string, *args)
        @logger.puts sprintf(string, *args) if @logger
      end

      def log(*args)
        logf('%s', *args)
      end

      def fatal(*args)
        log(*args)
        fail_now
      end

      def fatalf(string, *args)
        logf(string, *args)
        fail_now
      end

      def error(*args)
        log(*args)
        fail
      end

      def errorf(string, *args)
        logf(string, *args)
        fail
      end

      def skip_now
        @skipped = true
        raise TestSkip
      end

      def skip(*args)
        log(*args)
        skip_now
      end

      def skipf(string, *args)
        logf(string, *args)
        skip_now
      end

      def skipped?
        @skipped
      end
    end
  end
end
