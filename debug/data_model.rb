module Debug
  module DataModel
    include Debug

    def self.pretty_value(value, depth=0)
      return "..." if depth > 99
      case value
      when Array, Hash, Moon::DataModel::Model
        value_stream = ""
        pretty_obj_stream(value_stream, value, depth)
        return value_stream
      else
        value.inspect
      end
    end

    def self.pretty_type(type)
      case type
      when Array
        if type.size == 0
          "#{type.class}"
        elsif type.size == 1
          "#{type.class}<#{type.first}>"
        else
          "#{type.class}#{type.inspect}"
        end
      when Hash
        if type.size == 0
          "#{type.class}"
        elsif type.size == 1
          pair = type.first
          "#{type.class}<#{pair[0]}, #{pair[1]}>"
        else
          "#{type.class}#{type.inspect}"
        end
      else
        type.inspect
      end
    end

    def self.pretty_depth(str, depth)
      "#{"  "*depth}#{str}"
    end

    def self.pretty_model(stream, model, depth=0)
      stream << pretty_depth("struct #{model.class.inspect} {\n", depth)
      model.each_field_with_value do |key, field, value|
        stream << pretty_depth("  #{key}: #{pretty_type(field.type)} = #{pretty_value(value, depth+1)},\n", depth)
      end
      stream << pretty_depth("}", depth)
      stream
    end

    def self.pretty_obj_stream(stream, obj, depth=0)
      if obj.is_a?(Moon::DataModel::Model)
        pretty_model(stream, obj, depth)
      elsif obj.is_a?(Hash)
        stream << pretty_depth("{ # size: #{obj.size}\n", depth)
        obj.each do |k, v|
          stream << pretty_depth("#{pretty_value(k)}", depth+1)
          pretty_obj_stream(stream, value, depth+2)
          stream << ",\n"
        end
        stream << pretty_depth("}", depth)
      elsif obj.is_a?(Array)
        stream << pretty_depth("[ # size: #{obj.size}\n", depth)
        obj.each do |o|
          pretty_obj_stream(stream, o, depth+1)
          stream << ",\n"
        end
        stream << pretty_depth("]", depth)
      else
        stream << pretty_depth(pretty_value(obj) << "\n", depth)
      end
      stream
    end

    def self.pretty_print(obj, depth=0)
      puts pretty_obj_stream("", obj, depth)
    end
  end
end

module Moon
  module DataModel
    class Metal
      def ppd_dm(depth=0)
        Debug::DataModel.pretty_print(self, depth)
        self
      end
    end
  end
end
