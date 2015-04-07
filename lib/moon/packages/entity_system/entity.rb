module Moon
  module EntitySystem
    class Entity
      attr_reader :id

      def initialize(world)
        @world = world
        @id = @world.random.base64(16) # right within ruby's optimal string length
      end

      def ==(obj)
        self.id == obj.id
      end

      def components
        @world.get_components(self)
      end

      def add(component, options = {})
        case component
        when Hash
          component.map do |k, v|
            @world.add_component(self, Component.manager.fetch(k).new(v))
          end
        when Symbol
          @world.add_component(self, Component.manager.fetch(component).new(options))
        else
          @world.add_component(self, component)
        end
      end

      def get_component(key)
        @world.get_component(self, key)
      end
      alias :[] :get_component

      def []=(key, component)
        @world.set_component(self, key, component)
      end

      def comp(*keys)
        components = keys.map { |key| get_component(key) }
        yield(*components) if components.all? if block_given?
        components
      end

      def to_h
        {
          id: @id
        }
      end

      def export
        to_h.stringify_keys
      end

      def import(data)
        @id = data["id"]
        self
      end

      def inherit(entity)
        entity.components.each do |component|
          add(component.as_inheritance)
        end
      end
    end
  end
end
