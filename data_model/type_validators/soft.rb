module Moon
  module DataModel
    module TypeValidators
      module Soft
        include Moon::DataModel::TypeValidators::Base

        def check_array_type(type, key, value, options = {})
          check_object_class(key, Array, value, options)
          true
        end

        def check_hash_type(type, key, value, options = {})
          check_object_class(key, Hash, value, options)
          true
        end

        def check_normal_type(type, key, value, options = {})
          check_object_class(key, type, value, options)
          true
        end

        def check_type(type, key, value, options = {})
          if options[:allow_nil] && value.nil?
            return true
          elsif !options[:allow_nil] && value.nil?
            if options[:quiet]
              return false
            else
              raise TypeError, ":#{key} shall not be nil"
            end
          end
          # validate that obj is an Array and contains correct types
          case type
          when Array
            check_array_type(type, key, value, options)
          # validate that value is a Hash of key type and value type
          when Hash
            check_hash_type(type, key, value, options)
          # validate that value is of type
          when Module
            check_normal_type(type, key, value, options)
          else
            true
          end
        end

        private :check_hash_type
        private :check_array_type
        private :check_normal_type

        extend self
      end
    end
  end
end
