module Moon
  module System
    module ClassMethods
      def register(sym)
        System.list.delete(@registered) if @registered
        @registered = sym
        System.list[sym] = self
      end
    end

    module InstanceMethods
      attr_reader :world

      def initialize(world)
        @world = world
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

    @@system_list = {}

    def self.[](key)
      @@system_list[key]
    end

    def self.list
      @@system_list
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
