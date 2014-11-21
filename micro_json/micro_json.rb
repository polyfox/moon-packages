module MicroJSON
  ##
  # @param [Object] o
  # @return [String]
  def self.dump(o)
    dump_obj = lambda do |obj|
      result = ''
      case obj
      when Hash
        result << '{'
        result << (obj.map do |(key, value)|
          key.to_s.dump << ':' << dump_obj.call(value)
        end.join(','))
        result << '}'
      when String
        result << obj.dump
      when Symbol
        result << obj.to_s.dump
      when Numeric
        result << obj.to_s
      when Array
        result << '['
        result << (obj.map do |value|
          dump_obj.call(value)
        end.join(','))
        result << ']'
      when true
        result << 'true'
      when false
        result << 'false'
      when nil
        result << 'null'
      else
        result << obj.to_json
      end
      result
    end
    dump_obj.call(o)
  end

  ##
  # @param [String] str
  # @return [Object]
  def self.load(str)
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
