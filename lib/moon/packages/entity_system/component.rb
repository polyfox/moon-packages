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
          to_h.merge(component_type: symbol).stringify_keys
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

        mod.register mod.to_s.demodulize.downcase.to_sym
      end

      def self.load(data)
        self[data['component_type'].to_sym].new(data.symbolize_keys)
      end
    end
  end
end
