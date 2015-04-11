module Moon
  module Test
    class AssertError < StandardError
      attr_accessor :test_stack

      def initialize(stack, message)
        @test_stack = stack
        super message
      end
    end

    # Basic Assertion Framework
    module Assert
      class << self
        attr_accessor :fail_on_assert_error
      end

      self.fail_on_assert_error = true

      attr_accessor :fail_on_assert_error
      # whetehr or not to print out the err, only valid if fail_on_assert_error is false
      attr_accessor :assertion_quiet
      attr_reader :assertions
      attr_reader :assertion_errors

      ##
      # @return [Void]
      def init_assertions
        @fail_on_assert_error = Assert.fail_on_assert_error
        @assertions = 0
        @assertion_errors = 0
        @assertion_catcher = nil
        @assertion_quiet = true
      end
      private :init_assertions

      def catch_assertion_errors(&block)
        @assertion_catcher = block
      end

      ##
      # @param [String, nil] msg
      # @param [Exception, nil] original_exception
      def raise_assert_error(msg = nil, original_exception = nil)
        if original_exception
          message = (msg || "assertion failed\n") +
                    original_exception.inspect + "\n" +
                    original_exception.backtrace("\n").indent(2)
        else
          message = (msg || 'assertion failed.')
        end
        @assertion_errors += 1
        begin
          fail  # just to nab a backtrace
        rescue RuntimeError => ex
          # curry the error
          err = AssertError.new(ex.backtrace.dup.slice(1, ex.backtrace.size - 1),
                                message)
          fail err
        end
      rescue AssertError => err
        @assertion_catcher.call err if @assertion_catcher
        if @fail_on_assert_error
          fail err
        elsif !@assertion_quiet
          puts err.inspect
          puts err.backtrace.join("\n")
        end
      end
      private :raise_assert_error

      ##
      # @param [Object] obj
      # @param [String, nil] msg
      def assert(obj, msg = nil)
        @assertions += 1
        obj ? true : raise_assert_error(msg)
      end

      ##
      # @param [Object] obj
      # @param [String, nil] msg
      def assert_true(obj, msg = nil)
        assert(!!obj, msg || "expected #{obj.inspect} to be true.")
      end

      ##
      # @param [Object] obj
      # @param [String, nil] msg
      def assert_false(obj, msg = nil)
        assert_true(!obj, msg || "expected #{obj.inspect} to be false.")
      end

      ##
      # @param [Object] a
      # @param [Object] b
      # @param [String, nil] msg
      def assert_equal(a, b, msg = nil)
        assert_true(a == b, msg || "expected #{a.inspect} == #{b.inspect}.")
      end

      ##
      # @param [Object] a
      # @param [Object] b
      # @param [String, nil] msg
      def assert_not_equal(a, b, msg = nil)
        assert_true(a != b, msg || "expected #{a.inspect} != #{b.inspect}.")
      end

      ##
      # @param [Object] a
      # @param [Object] b
      # @param [String, nil] msg
      def assert_same(a, b, msg = nil)
        assert_true(a.equal?(b), msg || "expected #{a.inspect} to #equal? #{b.inspect}.")
      end

      ##
      # @param [Object] a
      # @param [Object] b
      # @param [String, nil] msg
      def assert_not_same(a, b, msg = nil)
        assert_false(a.equal?(b), msg || "expected #{a.inspect} to not #equal? #{b.inspect}.")
      end

      ##
      # @param [Object] a
      # @param [String, nil] msg
      def assert_nil(a, msg = nil)
        assert_equal(a, nil, msg)
      end

      ##
      # @param [Class<Exception>] klass
      # @param [String, nil] msg
      # @yield
      def assert_raise(klass, msg = nil)
        begin
          yield
        rescue Exception => e
          return assert_equal(e.class, klass, msg || "expected #{klass.inspect} to be raised")
        end
        raise_assert_error("expected #{klass.inspect} to be raised, but nothing was raised.")
      end

      ##
      # @param [String, nil] msg
      # @yield
      def assert_not_raise(msg = nil)
        @assertions += 1
        begin
          yield
        rescue Exception => e
          raise_assert_error(msg || 'expected nothing to be raised.', e)
        end
      end

      ##
      # @param [Class] klass
      # @param [Object] obj
      # @param [String, nil] msg
      def assert_kind_of(klass, obj, msg = nil)
        assert_true(obj.kind_of?(klass),
                    msg || "expected #{obj.inspect} to be kind_of? #{klass.inspect}.")
      end

      ##
      # @param [Array<Class>] klasses
      def assert_kind_of_any(klasses, obj, msg = nil)
        assert_true(klasses.any? { |klass| obj.kind_of?(klass) },
                    msg || "expected #{obj.inspect} to be kind_of any? #{klasses.inspect}")
      end

      ##
      # @param [Class] klass
      # @param [Object] obj
      # @param [String, nil] msg
      def assert_not_kind_of(klass, obj, msg = nil)
        assert_false(obj.kind_of?(klass),
                     msg || "expected #{obj.inspect} not to be kind_of? #{klass.inspect}.")
      end

      ##
      # @param [Float] exp
      # @param [Float] act
      # @param [String, nil] msg
      def assert_float(exp, act, msg = nil)
        assert_true(check_float(exp, act),
                    msg || "expected #{exp.inspect} to equal #{act.inspect}.")
      end

      ##
      # Swiped from mruby/test/assert
      # Performs fuzzy check for equality on methods returning floats
      #
      # @param [Float] a
      # @param [Float] b
      def check_float(a, b)
        #tolerance = 1e-12
        tolerance = 1e-2
        a = a.to_f
        b = b.to_f
        if a.finite? and b.finite?
          (a-b).abs < tolerance
        else
          true
        end
      end

      # extended
      def assert_ary_size(expected, ary, msg = nil)
        assert_equal(expected, ary.size,
                     msg || "expected Array of size #{expected.inspect}.")
      end

      # extended
      def assert_ary_include(expected, ary, msg = nil)
        assert_true(ary.include?(expected),
                    msg || "expected Array of to include #{expected.inspect}.")
      end

      # @param [Symbol, String] constname
      # @param [Module] parent
      # @param [String, nil] msg
      def assert_const_defined(constname, parent = nil, msg = nil)
        parent ||= ::Object
        assert_true(parent.const_defined?(constname),
                    msg || "expected #{constname.inspect} to be defined under #{parent.inspect}.")
      end

      # @param [Symbol, String] methodname
      # @param [Object] obj
      # @param [String, nil] msg
      def assert_respond_to(methodname, obj, msg = nil)
        assert_true(obj.respond_to?(methodname),
                    msg || "expected #{obj.inspect} to respond_to?(#{methodname.inspect}).")
      end

      # @param [Symbol, String] methodname
      # @param [Object] obj
      # @param [String, nil] msg
      def assert_method_defined(methodname, obj, msg = nil)
        assert_true(obj.method_defined?(methodname),
                    msg || "expected #{obj.inspect} to define #{methodname.inspect}.")
      end
    end

    include Assert
  end
end
