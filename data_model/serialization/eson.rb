module Moon
  module DataModel
    module ESON
      module ClassExtension
        ##
        # @param [Hash] data
        # @param [Integer] depth
        def load(data, depth=0)
          instance = new
          instance.import data, depth+1
          instance
        end
      end

      ##
      # @param [Object] obj
      # @param [Integer] depth
      # @return [Hash|Array]
      def export_obj(obj, depth=0)
        if obj.is_a?(Array)
          obj.map { |o| export_obj(o, depth+1) }
        elsif obj.is_a?(Hash)
          obj.each_with_object({}) do |a, hash|
            k, v = *a
            hash[k] = export_obj(v, depth+1)
          end
        else
          obj.respond_to?(:export) ? obj.export(depth+1) : obj
        end
      end

      ##
      # @param [Integer] depth
      # @return [Hash]
      def export(depth=0)
        hsh = {}
        each_field_name do |k|
          hsh[k] = export_obj(send(k), depth+1)
        end
        hsh["&class"] = self.class.to_s
        hsh.stringify_keys
      end

      ##
      # @param [Object] obj
      # @param [Integer] depth
      def import_obj(obj, depth=0)
        if obj.is_a?(Array)
          obj.map { |o| import_obj(o, depth+1) }
        elsif obj.is_a?(Hash)
          if obj.key?("&class")
            safe_obj = obj.dup
            klass_path = safe_obj.delete("&class")
            klass = Object.const_get(klass_path)
            klass.load safe_obj
          else
            obj.each_with_object({}) do |a, hash|
              k, v = *a
              hash[k] = import_obj(v, depth+1)
            end
          end
        else
          obj
        end
      end

      ##
      # Tries to load every field present using the data provided.
      # @param [Hash] data
      # @param [Integer] depth
      # @return [self]
      def import(data, depth=0)
        each_field_with_value do |k, _, value|
          if value.respond_to?(:import)
            value.import(data[k.to_s])
          else
            send("#{k}=", import_obj(data[k.to_s], depth+1))
          end
        end
        self
      end

      def self.included(mod)
        mod.extend ClassExtension
      end

      private :export_obj
      private :import_obj
    end
  end
end
