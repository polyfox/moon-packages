module Moon
  module DataModel
    module ESON
      module ClassExtension
        ##
        # @param [Hash] data
        def load(data)
          instance = new
          instance.import data
          instance
        end
      end

      ###
      # @return [Hash|Array]
      ###
      def export_obj(obj)
        if obj.is_a?(Array)
          obj.map { |o| export_obj(o) }
        elsif obj.is_a?(Hash)
          obj.each_with_object({}) do |a, hash|
            k, v = *a
            hash[k] = export_obj(v)
          end
        else
          obj.respond_to?(:export) ? obj.export : obj
        end
      end

      ###
      # @return [Hash]
      ###
      def export
        hsh = {}
        each_field_name do |k|
          hsh[k] = export_obj(send(k))
        end
        hsh["&class"] = self.class.to_s
        hsh.stringify_keys
      end

      ###
      # @param [Object] obj
      ###
      def import_obj(obj)
        if obj.is_a?(Array)
          obj.map { |o| import_obj(o) }
        elsif obj.is_a?(Hash)
          if obj.key?("&class")
            safe_obj = obj.dup
            klass_path = safe_obj.delete("&class")
            klass = Object.const_get(klass_path)
            klass.load safe_obj
          else
            obj.each_with_object({}) do |a, hash|
              k, v = *a
              hash[k] = import_obj(v)
            end
          end
        else
          obj
        end
      end

      ###
      # @param [Hash] data
      # @return [self]
      ###
      def import(data)
        each_field_name do |k|
          send("#{k}=", import_obj(data[k.to_s]))
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
