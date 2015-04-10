module Moon
  module Serializable
    # @abstract
    class Serializer
    end

    class Importer < Serializer
      # @param [String] klass_path
      # @param [String, Symbol] key
      # @param [Hash<String, Object>] value
      # @param [Integer] depth
      private def import_class(klass_path, key, value, depth = 0)
        Object.const_get(klass_path).load(value, depth + 1)
      end

      # @param [String, Symbol] key
      # @param [Object] value
      # @param [Integer] depth
      private def import_object(key, value, depth = 0)
        if value.is_a?(Array)
          value.map { |v| import_object(key, v, depth + 1) }
        elsif value.is_a?(Hash)
          if value.key?('&class')
            klass = value['&class']
            import_class(klass, key, value.exclude('&class'), depth + 1)
          else
            value.map { |k, v| [k, import_object(k, v, depth + 1)] }.to_h
          end
        else
          value
        end
      end

      # @param [#serialization_properties, #[]=] target
      # @param [#[]] data
      # @param [Integer] depth
      def import(target, data, depth = 0)
        target.serialization_properties do |key, _|
          target.property_set(key, import_object(key, data[key.to_s], depth + 1))
        end
        target
      end

      # @param [#serialization_properties, #[]=] target
      # @param [#[]] data
      # @param [Integer] depth
      def self.import(target, data, depth = 0)
        new.import(target, data, depth + 1)
      end
    end

    class Exporter < Serializer
      # @param [Symbol] key
      # @param [Object] value
      # @param [Integer] depth
      private def export_object(key, value, depth = 0)
        if value.respond_to?(:export)
          value.export({}, depth + 1)
        elsif value.is_a?(Array)
          value.map { |v| export_object(key, v, depth + 1) }
        elsif value.is_a?(Hash)
          value.map { |k, v| [k, export_object(k, v, depth + 1)] }.to_h
        else
          value
        end
      end

      # @param [#[]=] target
      # @param [#serialization_properties] data
      # @param [Integer] depth
      def export(target, data, depth = 0)
        data.serialization_properties do |key, value|
          target[key] = export_object(key, value, depth + 1)
        end
        target
      end

      # @param [Object] target
      # @param [Object] data
      # @param [Integer] depth
      def self.export(target, data, depth = 0)
        new.export(target, data, depth + 1)
      end
    end

    module InstanceMethods
      # @abstract
      # @yield [Array[Symbol, Object]]
      # :serialization_properties

      # @return [Hash<String, Object>]
      private def serialization_export_header
        {
          '&class' => self.class.to_s
        }
      end

      def property_set(key, value)
        self[key] = value
      end

      private def import_headless(data, depth = 0)
        Importer.import self, data.exclude('&class'), depth
      end

      # @param [Hash<[String, Symbol], Object>] data
      # @param [Integer] depth
      def import(data, depth = 0)
        import_headless data, depth
      end

      # @param [Integer] depth
      def export(data = nil, depth = 0)
        data = Exporter.export(data || {}, self, depth)
        data.merge!(serialization_export_header).stringify_keys
      end

      # Makes a copy of the Object using the .load and #export methods
      # This should not be confused with deep_clone, which uses Marshal.
      #
      # @return [Object]  copy of the object
      def copy
        self.class.load export
      end
    end

    module ClassMethods
      def load(data, depth = 0)
        new.import(data, depth)
      end
    end

    # @param [Module] mod
    def self.included(mod)
      mod.extend         ClassMethods
      mod.send :include, InstanceMethods
    end
  end
end
