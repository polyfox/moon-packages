# Minimal implementation of JSON using pure ruby.
module MicroJSON
  # Class for writing JSON streams.
  class Encoder
    # @!attribute [r] stream
    #   @return [#<<]
    attr_reader :stream

    # @param [#<<] stream
    # @param [Hash] options
    def initialize(stream, options = {})
      @options = options
      @stream = stream
    end

    # Write to the underlying stream
    #
    # @param [String] str
    # @param [Integer] depth
    def write(str, depth = 0)
      stream << str
    end

    # Write a String to the stream.
    #
    # @param [String] str
    # @param [Integer] depth
    def write_string(str, depth = 0)
      write(str.dump, depth + 1)
    end

    # Writes a Symbol to the stream, this is affected by the :symbols
    # option passed into the Encoder.
    # if :symbols is true, Symbol are JSON strings prefixed with :, otherwise
    # they appear as regular strings.
    #
    # @param [Symbol] sym
    # @param [Integer] depth
    def write_symbol(sym, depth = 0)
      if @options[:symbols]
        write_string(":#{sym}", depth = 0)
      else
        write_string(sym.to_s, depth = 0)
      end
    end

    # Writes a Numeric to the stream.
    #
    # @param [Numeric] num
    # @param [Integer] depth
    def write_number(num, depth = 0)
      write(num.to_s, depth + 1)
    end

    # Writes an Integer to the stream.
    #
    # @param [Integer] int
    # @param [Integer] depth
    def write_integer(int, depth = 0)
      write_number(int, depth + 1)
    end

    # Writes a Float to the stream.
    #
    # @param [Float] flt
    # @param [Integer] depth
    def write_float(flt, depth = 0)
      write_number(flt, depth + 1)
    end

    # Writes a Boolean to the stream.
    #
    # @param [Boolean] bool
    # @param [Integer] depth
    def write_boolean(bool, depth = 0)
      write(bool ? 'true' : 'false')
    end

    # Writes a nil to the stream
    #
    # @param [nil] null  not needed, only kept to match the other write methods.
    # @param [Integer] depth
    def write_null(null, depth = 0)
      write('null')
    end

    # Writes an Array to the stream.
    #
    # @param [Array] array
    # @param [Integer] depth
    def write_array(array, depth = 0)
      write('[')
      end_ = array.size - 1
      array.each_with_index do |value, i|
        write_value(value, depth + 1)
        write(',') unless i == end_
      end
      write(']')
    end

    # Writes a Hash to the stream.
    #
    # @param [Hash] object
    # @param [Integer] depth
    def write_object(object, depth = 0)
      write('{')
      end_ = object.size - 1
      object.each_with_index do |pair, i|
        k, v = *pair
        write("\"#{k}\":")
        write_value(v)
        write(',') unless i == end_
      end
      write('}')
    end

    # Writes a ruby Object to the stream, if the Type cannot be matched,
    # the object is dumped using #to_json, if the object does not define a
    # #to_json method a TypeError is raised.
    #
    # @param [Object, #to_json] value
    # @param [Integer] depth
    def write_value(value, depth = 0)
      case value
      when String      then write_string(value, depth + 1)
      when Symbol      then write_symbol(value, depth + 1)
      when Integer     then write_integer(value, depth + 1)
      when Float       then write_float(value, depth + 1)
      when Array       then write_array(value, depth + 1)
      when Hash        then write_object(value, depth + 1)
      when true, false then write_boolean(value, depth + 1)
      when nil         then write_null(value, depth + 1)
      else
        if value.respond_to?(:to_json)
          write(value.to_json, depth + 1)
        else
          raise TypeError,
                "cannot encode #{value} (of type #{value.class})."
        end
      end
    end

    # Dumps provided object as JSON and returns the result.
    #
    # @param [Object] obj
    # @param [Hash] options
    # @param [Integer] depth
    def self.encode(obj, options = {}, depth = 0)
      result = ''
      new(result, options).write_value(obj, depth)
      result
    end
  end

  # Class for decoding JSON streams.
  class Decoder
    # Utility class for tracking String index position and retrieving values.
    class StringCursor
      # @!attribute [r] str
      #   @return [String]
      attr_reader :str

      # @!attribute [rw] index
      #   @return [Integer]
      attr_accessor :index

      # @param [String] str
      def initialize(str)
        @index = 0
        @str = str
      end

      # Have we reached the end of the String?
      #
      # @return [Boolean]
      def eos?
        @index >= @str.length
      end

      # Return the current character
      #
      # @return [String]
      def char
        @str[@index]
      end

      # Return a string from the current position
      #
      # @param [Integer] length
      # @return [String]
      def string(length)
        @str[@index, length]
      end

      # Decrements the index and returns the character at that point
      #
      # @return [String]
      def prev
        raise RangeError, 'stepping outside string\'s range' if @index <= 0
        @index -= 1
        char
      end

      # Increments the index and returns the character at that point
      #
      # @return [String]
      def next
        raise RangeError, 'stepping outside string\'s range' if @index >= @str.length
        @index += 1
        char
      end
    end

    # Generic error raised by the Decoder
    class ReadError < RuntimeError
    end

    # Error raised when a loop ended without completeing its operation,
    # such a string without its final "
    class UnexpectedEnd < ReadError
    end

    # Error raised when a invalid character is encountered.
    # Invalid may mean, finding a keyword or object, when a : was expected.
    class UnexpectedChar < ReadError
    end

    # Variation of UnexpectedChar for handling Strings
    class UnexpectedString < ReadError
    end

    # Error raised when an Invalid numeric seqeucne is found.
    class InvalidNumeric < ReadError
    end

    def initialize(options)
      @options = options
    end

    # Skips all characters in the stream until a newline or the end
    # is encountered.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    def skip_line(cur, depth = 0)
      cur.next until cur.eos? || cur.char == "\n"
      cur.next
    end

    # Skips all spaces, tabs and newlines in the stream until something else
    # is encountered.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    def skip_spaces(cur, depth = 0)
      # skip spaces, tabs and new lines
      while cur.char == " " || cur.char == "\t" || cur.char == "\n"
        cur.next
      end
    end

    # Reads the stream value after a " character as a String.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [String]
    def read_string_body(cur, depth = 0)
      s = ''
      end_found = false
      until cur.eos?
        case c = cur.char
        when '\\'
          cur.next
          break if cur.eos?
          s << cur.char
          cur.next
        when '"'
          end_found = true
          cur.next
          break
        else
          s << c
          cur.next
        end
      end
      raise UnexpectedEnd, 'Unexpected end of string.' unless end_found
      s = s.slice(1, s.length - 1).to_sym if @options[:symbols] && s.start_with?(':')
      s
    end

    # Reads the first " that can be found from the current cursor position.
    # If the first valid character is not an ",
    # an UnexpectedChar error is raised.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [String]
    def read_string(cur, depth = 0)
      skip_spaces cur, depth + 1
      unless cur.char == '"'
        raise UnexpectedChar, "expected \" (got #{cur.char})"
      end
      cur.next
      read_string_body cur
    end

    # Reads a String using #read_string followed by a :.
    # If the next character after the string is not a :, and UnexpectedChar
    # error is raised.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [String]
    def read_object_key(cur, depth = 0)
      s = read_string cur, depth + 1
      skip_spaces cur
      unless cur.char == ':'
        raise UnexpectedChar, "expected : (got #{cur.char})"
      end
      cur.next
      s
    end

    # Reads the next sequence in the stream as a Numeric value.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [Numeric]
    def read_numeric(cur, depth = 0)
      skip_spaces cur, depth + 1
      base = 10
      n = ''
      f = false # is float
      neg = false
      if cur.char == '-' || cur.char == '+'
        n << cur.char
        cur.next
      end
      until cur.eos?
        case c = cur.char
        when '0'..'9'
          n << c
        when 'A'..'F', 'a'..'f'
          unless base == 16
            raise UnexpectedChar, "reading HEX values for non HEX value."
          end
          n << c
        when 'x', 'X'
          raise InvalidNumeric, "cannot read a HEX and float value." if f
          base = 16
        when '.'
          raise InvalidNumeric, "cannot read a HEX and float value." if base == 16
          f = true
          n << c
        else
          break
        end
        cur.next
      end
      f ? n.to_f : n.to_i(base)
    end

    # Reads the next sequence in the stream as a keyword.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [Object] value of the keyword
    def read_keyword(cur, depth = 0)
      if cur.string(4) == 'true'
        cur.index += 4
        return true
      elsif cur.string(5) == 'false'
        cur.index += 5
        return false
      elsif cur.string(4) == 'null'
        cur.index += 4
        return nil
      else
        return UnexpectedString, 'expected false, null, or true.'
      end
    end

    # Reads the next value from the sequence.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [Object]
    def read_value(cur, depth = 0)
      skip_spaces cur, depth + 1
      until cur.eos?
        case cur.char
        when 'a'..'z', 'A'..'Z'
          return read_keyword cur, depth + 1
        when '-', '+', '0'..'9'
          return read_numeric cur, depth + 1
        when '['
          cur.next
          return read_array_body cur, depth + 1
        when '"'
          cur.next
          return read_string_body cur, depth + 1
        when '{'
          cur.next
          return read_object_body cur, depth + 1
        # comment
        when '//'
          skip_line cur, depth + 1
        when ' ', "\t", "\n"
          cur.next
        else
          break
        end
      end
    end

    # Reads until a , or the provided character +c+ is reached.
    #
    # @param [String] c
    # @param [StringCursor] cur
    # @param [Integer] depth
    def read_boundry(c, cur, depth = 0)
      #puts "reading boundry for #{c}"
      skip_spaces cur, depth + 1
      until cur.eos?
        case cur.char
        when c
          return
        when ','
          return
        when '//'
          skip_line cur, depth + 1
        when ' ', "\t", "\n"
          cur.next
        else
          raise
        end
      end
      raise UnexpectedEnd, 'Unexpected end.' unless end_found
    end

    # Skips along in the stream until a ], or , is encountered
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    def read_array_continuation(cur, depth = 0)
      read_boundry ']', cur, depth
    end

    # Reads the contents of an Array after after a [ character.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [Array]
    def read_array_body(cur, depth = 0)
      skip_spaces cur, depth + 1
      a = []
      end_found = false
      until cur.eos?
        case cur.char
        when ']'
          cur.next
          end_found = true
          break
        when ','
          cur.next
        else
          skip_spaces cur, depth + 1
          a << read_value(cur, depth + 1)
          read_array_continuation cur, depth + 1
        end
      end
      raise UnexpectedEnd, 'Unexpected end of Array.' unless end_found
      a
    end

    # Reads stream until a continuation or end character is found.
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [Void]
    def read_object_continuation(cur, depth = 0)
      read_boundry '}', cur, depth
    end

    # Reads the contents of an Object after the { character
    #
    # @param [StringCursor] cur
    # @param [Integer] depth
    # @return [Hash]
    def read_object_body(cur, depth = 0)
      skip_spaces cur
      h = {}
      end_found = false
      until cur.eos?
        case cur.char
        when '}'
          cur.next
          end_found = true
          break
        when ','
          cur.next
        else
          key = read_object_key cur, depth + 1
          value = read_value cur, depth + 1
          h[key] = value
          read_object_continuation cur, depth + 1
        end
      end
      raise UnexpectedEnd, 'Unexpected end of Hash/Object.' unless end_found
      h
    end

    # Decodes a JSON string as ruby.
    #
    # @param [String] str
    # @param [Integer] depth
    # @return [Object]
    def decode(str, depth = 0)
      read_value StringCursor.new(str), depth
    end

    # Decodes a JSON string as ruby.
    #
    # @param [String] str
    # @param [Hash] options
    # @return [Object]
    def self.decode(str, options = {}, depth = 0)
      new(options).decode(str, depth)
    end
  end

  # Dump a ruby object to JSON.
  #
  # @param [Object] o
  # @param [Hash] options
  #   @option options [Boolean] :symbols  should symbols be dumped appended with ':' ?
  # @return [String]
  def self.dump(o, options = {})
    Encoder.encode(o, options)
  end

  # Load a JSON object as ruby.
  #
  # @param [String] str
  # @return [Object]
  def self.load(str, options = {})
    Decoder.decode(str, options)
  end
end
