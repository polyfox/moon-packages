require 'entity_system/component'

module Moon
  module EntitySystem
    class Entity
      # @!attribute [r] id
      #   @return [String]
      attr_reader :id

      # @param [World] world
      def initialize(world)
        @world = world
        initialize_id
      end

      # Removes the entity from its parent world
      #
      # @return [void]
      def destroy
        @world.remove_entity(self)
      end

      # Initializes the ID attribute
      #
      # @return [void]
      private def initialize_id
        # 16 should be right within ruby's optimal string length
        @id = @world.random.base64(16)
      end

      # Compares an Object with the Entity, returns false if the Object is
      # not an entity.
      #
      # @param [Object] other
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(Entity)
        self.id == other.id
      end

      # Returns a list of all the components attached to this entity
      #
      # @return [Array<Component>]
      def components
        @world.get_components(self)
      end

      # Adds a new component to the Entity
      #
      # @overload add(component)
      #   @param [Component] component
      # @overload add(hash)
      #   @param [Hash<Symbol, Hash>] hash
      # @overload add(component_name, options)
      #   @param [Symbol] component_name
      #   @param [Hash] options
      def add(component, options = {})
        case component
        when Hash
          component.each_with_object({}) { |pair, r| r[pair[0]] = add(*pair) }
        when Symbol
          @world.add_component(self, Component.manager.fetch(component).new(options))
        else
          @world.add_component(self, component)
        end
      end

      # Removes a component from the entity
      #
      # @param [Array<Component, Symbol>] components
      def remove(*components)
        components.each { |component| @world.remove_component(self, component) }
      end

      # Retrieves a component by key
      #
      # @param [Symbol] key
      # @return [Component]
      def get(key)
        @world.get_component(self, key)
      end
      alias :[] :get

      # Sets a component by key
      #
      # @param [Symbol] key
      # @param [Component] component
      def []=(key, component)
        @world.set_component(self, key, component)
      end

      # Yields components under the given keys, if any of the components are
      # missing, nothing is yielded.
      #
      # @param [Array<Symbol>] keys
      # @yieldparam [Array<Component>] *components
      # @return [Array<Component>]
      def comp(*keys)
        result = keys.map { |key| get(key) }
        yield(*result) if result.all? if block_given?
        result
      end

      # Copies components from from another entity
      #
      # @param [Entity] entity
      def copy(entity)
        entity.components.each do |component|
          add(component.as_inheritance)
        end
      end

      # Returns the entity's data as a Hash
      #
      # @return [Hash]
      def to_h
        {
          id: @id
        }
      end

      # Serializable export api
      #
      # @return [Hash]
      def export
        to_h.stringify_keys
      end

      # Serializable import api
      #
      # @param [Hash] data
      def import(data)
        @id = data["id"]
        self
      end
    end
  end
end
