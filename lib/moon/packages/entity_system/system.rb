module Moon
  module EntitySystem
    module System
      @@manager = {}

      # @return [Hash<Symbol, Class<System>>]
      def self.manager
        @@manager
      end

      module ClassMethods
        attr_reader :registered

        # Registers the system under (name)
        #
        # @param [Symbol] name
        # @return [self]
        def register(name)
          System.manager.delete(@registered) if @registered
          @registered = name.to_sym
          System.manager[@registered] = self
          self
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
        attr_reader :world

        # @param [EntitySystem::World] world
        def initialize(world)
          @world = world
          post_initialize
        end

        # Called after initialization
        def post_initialize
          #
        end

        # @param [Float] delta
        def update(delta)
          #
        end

        # @param [Integer] x
        # @param [Integer] y
        # @param [Integer] z
        # @param [Hash] options
        def render(x = 0, y = 0, z = 0, options = {})
          #
        end

        # Overwrite this method in your base class to add serializable
        # properties
        #
        # @return [Hash<Symbol, Object>]
        def to_h
          {}
        end

        # Serializable interface, use this method to dump a system state
        #
        # @return [Hash<String, Object>]
        def export
          to_h.merge(system_name: self.class.registered.to_s).stringify_keys
        end

        # Serializable interface, use this method to reload a system state
        #
        # @param [Hash<String, Object>]
        # @return [self]
        def import(data)
          self
        end
      end

      # @param [Module] mod  module that included this
      def self.included(mod)
        mod.extend         ClassMethods
        mod.send :include, InstanceMethods
        mod.autoregister
      end

      # Creates a new System, the system is taken from its marshalled
      # system_name
      #
      # @param [Moon::EntitySystem::World] world
      # @param [Hash<String, Object>] data
      # @return [Moon::EntitySystem::System]
      def self.new(world, data)
        system_name = data['system_name'].to_sym
        manager.fetch(system_name).new(world).tap do |sys|
          sys.import(data.symbolize_keys)
        end
      end
    end
  end
end
