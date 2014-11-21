module Moon
  module ArgsHelper
    class Result
      attr_accessor :valid
      attr_accessor :args

      def initialize(valid, args)
        @valid = valid
        @args = args
      end

      def valid?
        @valid
      end
    end

    def self.test_arg?(arg, expected_klass)
      arg.is_a?(expected_klass)
    end

    def self.test_arg_push(target, arg, expected_klass)
      if test_arg?(arg, expected_klass)
        target.push(arg)
        true
      else
        false
      end
    end

    def self.test_arg_concat(target, arg, expected_klass)
      if test_arg?(arg, expected_klass)
        target.concat(arg)
        true
      else
        false
      end
    end

    # format specifiers - Based on mruby mrb_get_args
    #  *:      rest                       -> (ary)
    #  A:      Array                      -> (ary)
    #  a:      Array (expanded)           -> (*ary)
    #  b:      Boolean                    -> (bool)
    #  C:      Class                      -> (klass)
    #  f:      Float                      -> (flt)
    #  H:      Hash                       -> (hsh)
    #  i:      Integer                    -> (int)
    #  n:      Symbol                     -> (sym)
    #  o:      Object                     -> (obj)
    #  O:      Object (of type) [Class]   -> (obj)
    #  S:      String                     -> (str)
    #  |:      optional
    # @param [Array] array  source array
    # @param [String] format  args format
    # @param [Object] args  helper args
    def self.get_args(array, format, *args)
      result = []
      arg_index = 0
      ary_index = 0
      optional = false
      valid = true

      next_arg = lambda do
        value = args[arg_index]
        arg_index += 1
        value
      end

      next_ary = lambda do
        value = array[ary_index]
        ary_index += 1
        value
      end

      add_arg_as = lambda do |klass|
        if test_arg_push(result, next_ary.(), klass) || optional
          true
        else
          valid = false
          false
        end
      end

      concat_arg_as = lambda do |klass|
        if test_arg_concat(result, next_ary.(), klass) || optional
          true
        else
          valid = false
          false
        end
      end

      format.split('').each_with_index do |char, i|
        case char
        when '*'
          result << array[ary_index, array.size - ary_index]
        when 'A'
          break unless add_arg_as.(Array)
        when 'a'
          break unless concat_arg_as.(Array)
        when 'b'
          break unless add_arg_as.(Boolean)
        when 'C'
          break unless add_arg_as.(Class)
        when 'f'
          break unless add_arg_as.(Float)
        when 'H'
          break unless add_arg_as.(Hash)
        when 'i'
          break unless add_arg_as.(Integer)
        when 'n'
          break unless add_arg_as.(Symbol)
        when 'o'
          break unless add_arg_as.(Object)
        when 'O'
          break unless add_arg_as.(next_arg.())
        when 'S'
          break unless add_arg_as.(String)
        when '|'
          optional = true
        end
      end

      yield(*result) if valid && block_given?

      Result.new(valid, result)
    end
  end
end
