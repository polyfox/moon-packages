module MicroJSON
  class Writer
    attr_reader :stream
    attr_reader :options

    def initialize(stream, options = {})
      @options = options
      @stream = stream
    end

    def write(str, depth = 0)
      stream << str
    end

    def write_string(str, depth = 0)
      write(str.dump, depth + 1)
    end

    def write_symbol(sym, depth = 0)
      if options[:symbols]
        write_string(":#{sym}", depth = 0)
      else
        write_string(sym.to_s, depth = 0)
      end
    end

    def write_number(num, depth = 0)
      write(num.to_s, depth + 1)
    end

    def write_integer(int, depth = 0)
      write_number(int, depth + 1)
    end

    def write_float(flt, depth = 0)
      write_number(flt, depth + 1)
    end

    def write_boolean(bool, depth = 0)
      write(bool ? 'true' : 'false')
    end

    def write_null(null, depth = 0)
      write('null')
    end

    def write_array(array, depth = 0)
      write('[')
      end_ = array.size - 1
      array.each_with_index do |value, i|
        write_value(value, depth + 1)
        write(',') unless i == end_
      end
      write(']')
    end

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
                "unexpected type #{value.class} (expected Integer, Float, Array, Hash or #to_json)"
        end
      end
    end
  end

  class Reader
  end

  ##
  # @param [Object] o
  # @param [Hash] options
  #   @option options [Boolean] :symbols  should symbols be dumped appended with ':' ?
  # @return [String]
  def self.dump(o, options = {})
    result = ''
    w = Writer.new(result, options)
    w.write_value(o)
    result
  end

  ##
  # @param [String] str
  # @return [Object]
  def self.load(str, options = {})
    index = 0

    read_array = nil
    read_hash = nil
    read_key_str = nil
    read_obj = nil
    read_str = nil

    current_char = lambda do |length=1|
      str[index, length]
    end

    read_str = lambda do
      old_index = index
      s = ''
      while index < str.size
        case c=current_char.call
        when '\\'
          index += 1
          s << current_char.call
          index += 1
        when '"'
          index += 1
          break
        else
          s << c
          index += 1
        end
      end
      s
    end

    read_str_find_first = lambda do
      while index < str.size
        case current_char.call
        when '"'
          index += 1
          return read_str.call
        else
          index += 1
        end
      end
    end

    read_key_str = lambda do
      s = read_str_find_first.call
      while index < str.size
        case current_char.call
        when ':'
          index += 1
          break
        else
          index += 1
        end
      end
      s
    end

    read_numeric = lambda do
      float = false
      base = 10
      n = ''
      while index < str.size
        case c = current_char.call
        when '-', '+', '0'..'9', 'A'..'F', 'a'..'f'
          n << c
        when 'x', 'X'
          base = 16
        when '.'
          float = true
          n << c
        else
          break
        end
        index += 1
      end
      if float
        n.to_f
      else
        n.to_i(base)
      end
    end

    read_obj = lambda do
      while index < str.size
        case current_char.call
        when 't'
          if current_char.call(4) == 'true'
            index += 4
            return true
          end
        when 'f'
          if current_char.call(5) == 'false'
            index += 5
            return false
          end
        when 'n'
          if current_char.call(4) == 'null'
            index += 4
            return nil
          end
        when '-', '+', '0'..'9'
          return read_numeric.call
        when '['
          index += 1
          return read_array.call
        when '"'
          index += 1
          return read_str.call
        when '{'
          index += 1
          return read_hash.call
        else
          index += 1
        end
      end
    end

    read_array_continue_or_end = lambda do
      while index < str.size
        case current_char.call
        when ']'
          break
        when ','
          break
        else
          index += 1
        end
      end
    end

    read_array = lambda do
      a = []
      while index < str.size
        case current_char.call
        when ']'
          index += 1
          break
        else
          a << read_obj.call
          read_array_continue_or_end.call
        end
      end
      a
    end

    read_hash_continue_or_end = lambda do
      while index < str.size
        case current_char.call
        when '}'
          break
        when ','
          break
        else
          index += 1
        end
      end
    end

    read_hash = lambda do
      h = {}
      while index < str.size
        case current_char.call
        when '}'
          index += 1
          break
        else
          key = read_key_str.call
          value = read_obj.call
          h[key] = value
          read_hash_continue_or_end.call
        end
      end
      h
    end

    read_obj.call
  end
end
