module Moon
  module EntitySystem
    module System
      @@manager = Manager.new

      def self.manager
        @@manager
      end

      module ClassMethods
        attr_reader :registered

        # @param [Symbol] sym
        def register(sym)
          System.manager.remove(@registered) if @registered
          @registered = sym
          System.manager.set(@registered, self)
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

      def self.included(mod)
        mod.extend         ClassMethods
        mod.send :include, InstanceMethods
        mod.register mod.to_s.demodulize.downcase.to_sym
      end

      def self.load(data)
        Object.const_get data["&class"]
      end
    end
  end
end
