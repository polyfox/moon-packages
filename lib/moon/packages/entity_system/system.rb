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

        def to_h
          {
            :"&class" => to_s
          }
        end

        # Serializable
        def export
          to_h.stringify_keys
        end

        # Serializable
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

      def self.load(data)
        Object.const_get data["&class"]
      end
    end
  end
end
