module Debug
  # Debugging Module for Moon::DataModel(s)
  module DataModel
    module PrettyFormat
      def self.array_type(array)
        case array.size
        when 0
          "#{array.class}"
        when 1
          "#{array.class}<#{array.first}>"
        else
          "#{array.class}#{array.inspect}"
        end
      end

      def self.hash_type(hash)
        case hash.size
        when 0
          "#{hash.class}"
        when 1
          pair = hash.first
          "#{hash.class}<#{pair[0]}, #{pair[1]}>"
        else
          "#{hash.class}#{hash.inspect}"
        end
      end

      def self.object_type(type)
        case type
        when Array
          array_type(type)
        when Hash
          hash_type(type)
        else
          type.inspect
        end
      end
    end

    # Streamer object
    class PrettyPrintStreamer
      attr_accessor :indent_level
      attr_accessor :comment_delimiter
      attr_accessor :indent_delimiter
      attr_accessor :list_delimiter

      def initialize(stream, from = nil)
        @stream = stream
        @indent_level = 0
        @comment_delimiter = '#'
        @indent_delimiter = "\s\s"
        @list_delimiter = ','
        if from
          @comment_delimiter = from.comment_delimiter
          @indent_delimiter = from.indent_delimiter
          @list_delimiter = from.list_delimiter
        end
      end

      def new(s = stream)
        self.class.new(s, self)
      end

      def endl
        "\n"
      end

      def unindent
        @indent_level = [@indent_level - 1, 0].max
      end

      def indent
        @indent_level += 1
        if block_given?
          yield
          unindent
        end
      end

      private def indent_str
        @indent_delimiter * @indent_level
      end

      def write(str)
        @stream.write str
      end

      def write_indent(depth = 0)
        write indent_str
      end

      def write_indented(str, depth = 0)
        write_indent depth
        write str
      end

      def write_endl(depth = 0)
        write endl
      end

      def write_line(str, depth = 0)
        write str
        write_endl depth
      end

      def write_comment_line(str, depth = 0)
        write @comment_delimiter
        write_line ' ' << str
      end

      def write_field(field, key, value, depth = 0)
        write_indented '' << key.to_s << ': ' <<
          PrettyFormat.object_type(field.type) << ' = '
        write_object(value)
      end

      def write_model(model, depth = 0)
        write_indented 'model ' << model.class.inspect << ' {' << endl
        indent do
          model.each_field_with_value do |key, field, value|
            write_field(field, key, value)
            write @list_delimiter
            write_endl
          end
        end
        write_indented '}'
      end

      def write_array(array, depth = 0)
        write_indented '[ '
        write_comment_line 'size: ' << array.size.to_s
        indent do
          array.each do |obj|
            write_object obj, depth.succ
            write @list_delimiter
            write_endl depth.succ
          end
        end
        write_indented ']'
      end

      def write_hash(hash, depth = 0)
        write_indented '{ '
        write_comment_line 'size: ' << hash.size.to_s
        indent do
          hash.each do |key, value|
            write_object key, depth.succ
            write ' => '
            write_object obj, depth.succ
            write @list_delimiter
            write_endl depth.succ
          end
        end
        write_indented '}'
      end

      def write_object(obj, depth = 0)
        case obj
        when Array
          write_array obj, depth.succ
        when Hash
          write_hash obj, depth.succ
        when Moon::DataModel::Model
          write_model obj, depth.succ
        else
          write obj.inspect
        end
      end
    end

    def self.pretty_print(obj, depth = 0)
      streamer = PrettyPrintStreamer.new(STDOUT)
      streamer.write_object(obj, depth)
      streamer.write_endl
    end
  end
end

module Moon
  module DataModel
    module Model
      def pretty_print_model(depth = 0)
        Debug::DataModel.pretty_print(self, depth)
        self
      end
    end
  end
end
