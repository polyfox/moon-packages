# Component as mixin
module Moon
  module EntitySystem
    module Component
      @@manager = Manager.new

      def self.manager
        @@manager
      end

      module ClassMethods
        attr_reader :registered

        def register(sym)
          Component.manager.remove(@registered) if @registered
          @registered = sym
          Component.manager.set(@registered, self)
        end
      end

      module InstanceMethods
        def initialize(options = {})
          setup(options)
        end

        def symbol
          self.class.registered
        end

        private def setup(options = {})
          each_field do |key, field|
            if options.key?(key)
              send("#{key}=", options[key]) if options.key?(key)
            else
              init_field(key)
            end
          end
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
