require 'data_model/fields'
require 'std/core_ext/hash'

# Component as mixin
module Moon
  module EntitySystem
    module Component
      @@manager = {}

      # @return [Hash<Symbol, Class<Component>>]
      def self.manager
        @@manager
      end

      module ClassMethods
        attr_reader :registered

        # Registers the component under (name)
        #
        # @param [Symbol] name
        # @return [self]
        def register(sym)
          Component.manager.delete(@registered) if @registered
          @registered = sym.to_sym
          Component.manager[@registered] = self
        end

        # Registers the system using its class name
        #
        # @return [self]
        def autoregister
          register to_s.demodulize.downcase.to_sym
          self
        end
      end

      module InstanceMethods
        def initialize(options = {})
          initialize_fields(options)
        end

        def symbol
          self.class.registered
        end

        def to_h
          fields_hash
        end

        def export
          to_h.merge(component_name: symbol.to_s).stringify_keys
        end

        def import(data)
          setup(data)
          self
        end

        def as_inheritance
          { symbol => to_h }
        end
      end

      def self.included(mod)
        mod.send :include, Moon::DataModel::Fields
        mod.extend         ClassMethods
        mod.send :include, InstanceMethods

        mod.autoregister
      end

      # Creates a Component from the given data, the component
      # is inferred from the `component_name`
      #
      # @param [Hash<String, Object>] data
      # @return [Component]
      def self.new(data)
        klass = manager.fetch(data['component_name'].to_sym)
        klass.new(data.exclude('component_name').symbolize_keys)
      end
    end
  end
end
