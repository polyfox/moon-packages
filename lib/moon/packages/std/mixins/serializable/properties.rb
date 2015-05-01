require 'moon-prototype/load'

module Moon
  module Serializable
    # Properties are special attributes on an object, its default implementation,
    # is to use instance variables, to change this overwrites the
    # #property_get and #property_set methods.
    module Properties
      module ClassMethods
        extend Moon::Prototype

        prototype_attr :property

        # Adds +name+ as a property of the class.
        #
        # @param [String, Symbol] name
        # @return [Symbol] name of the property
        private def add_property(name)
          name = name.to_sym
          properties << name
          name
        end

        # Equivalent to attr_reader property(name)
        # @param [String, Symbol] name
        # @return [Void]
        private def property_reader(name)
          attr_reader add_property(name)
        end

        # Equivalent to attr_writer property(name)
        # @param [String, Symbol] name
        # @return [Void]
        private def property_writer(name)
          attr_writer add_property(name)
        end

        # Equivalent to attr_accessor property(name)
        # @param [String, Symbol] name
        # @return [Void]
        private def property_accessor(name)
          attr_accessor add_property(name)
        end
      end

      module InstanceMethods
        # @param [Symbol] key
        def property_get(key)
          instance_variable_get "@#{key}"
        end

        # @param [Symbol] key
        # @param [Object] value
        def property_set(key, value)
          instance_variable_set "@#{key}", value
        end

        # @yieldparam [Symbol] key
        # @yieldparam [Object] value
        def each_property
          return to_enum :each_property unless block_given?
          self.class.all_properties.each do |key|
            yield key, property_get(key)
          end
        end

        def map_properties
          each_property do |key, value|
            property_set key, yield(key, value)
          end
        end

        def to_h
          # This may be a bit slower than creating a result hash and setting
          # each key from the property.
          each_property.to_a.to_h
        end

        def serialization_properties(&block)
          each_property(&block)
        end

        def serializable_inspect
          ptr = format('%x', __id__)
          result = "<#{self.class}#0x#{ptr}: "
          each_property do |key, value|
            s = case value
            when Hash then '{...}'
            when Array then '[...]'
            else
              value.inspect
            end
            result << "#{key}=#{s} "
          end
          result[-1] = '>'
          result
        end

        def inspect
          serializable_inspect
        end
      end

      # @param [Module] mod
      def self.included(mod)
        mod.extend         ClassMethods
        mod.send :include, InstanceMethods
      end
    end
  end
end
