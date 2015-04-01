module Moon #:nodoc:
  module EntitySystem #:nodoc:
    module System
      @@manager = Manager.new

      def self.manager
        @@manager
      end

      module ClassMethods
        attr_reader :registered

        def register(sym)
          System.manager.remove(@registered) if @registered
          @registered = sym
          System.manager.set(@registered, self)
        end
      end

      module InstanceMethods
        attr_reader :world

        def initialize(world)
          @world = world
          init
        end

        def init
          #
        end

        def update(delta)
          #
        end

        def process(delta, entity)
          #
        end

        def to_h
          {
            :"&class" => to_s
          }
        end

        def export
          to_h.stringify_keys
        end

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
        Object.const_get(data["&class"])
      end
    end
  end
end
