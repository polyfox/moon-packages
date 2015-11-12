require 'entity_system/entity'
require 'entity_system/system'
require 'entity_system/component'

module Moon
  module EntitySystem
    class World
      # @!attribute [r] components
      #   @return [Hash<Symbol, Hash<Entity, Array<Component>>>]
      attr_reader :components

      # @!attribute [r] entities
      #   @return [Array<Entity>]
      attr_reader :entities

      # @!attribute [r] random
      #   @return [Random] the random number generator for the world.
      attr_reader :random

      def initialize
        @random = Random.new
        # Hash<Symbol, Hash<Entity, Component>>
        # @components = { ComponentClass => {entity_id => [component, ...], ...}, ...}
        # subkeys always initialized to {}
        @components = Hash.new { |hash, key| hash[key] = {} }
        @entities = []
        @systems = []
      end

      # Initializes a copy of the world
      #
      # @param [World] other
      # @return [self]
      def initialize_copy(other)
        @components = @components.dup
        @entities = @entities.dup
        @systems = @systems.dup
        import(other.export)
        self
      end

      # Recreates the random generator from the existing one.
      private def reset_random
        @random = Random.new @random.seed
      end

      # Clears all entities, components and systems, skips callbacks.
      #
      # @return [self]
      def clear
        reset_random
        @components.clear
        @entities.clear
        @systems.clear
        self
      end

      # Synchronizes components and entities, this removes zombie components.
      def refresh
        components = {}
        @components.each_pair do |component_name, comps|
          rehashed = @entities.each_with_object({}) do |entity, dest|
            dest[entity] = comps[entity]
          end
          components[component_name] = rehashed
        end
        @components.replace(components)
      end

      # Sets a component, if given nil, the component is removed instead.
      #
      # @param [Entity] entity
      # @param [Symbol] component_sym
      # @param [Component, nil] component
      # @return [Component]
      private def set_component(entity, component_sym, component)
        comps = @components[component_sym]
        if component
          comps[entity] = component
        else
          comps.delete(entity)
        end
        component
      end

      # Retrieves an Entity's component by component name
      #
      # @param [Entity] entity
      # @param [Symbol] component_sym
      # @return [Component]
      def get_component(entity, component_sym)
        @components[component_sym][entity]
      end

      # Get all components associated with the provided Entity
      #
      # @param [Entity] entity
      # @return [Array<Component>]  components
      def get_components(entity)
        @components.each_with_object([]) do |pair, acc|
          _, entities = *pair
          if comp = entities[entity]
            acc.push(comp)
          end
        end
      end

      # Adds a component for the given entity
      #
      # @param [Entity] entity
      # @param [Component] component
      def add_component(entity, component)
        component_sym = component.symbol
        set_component entity, component_sym, component
      end

      # Removes a component for an entity by symbol
      #
      # @param [Entity] entity
      # @param [Symbol] component_sym
      def remove_component_by_symbol(entity, component_sym)
        set_component entity, component_sym, nil
      end

      # Removes a component
      #
      # @param [Entity] entity
      # @param [Component] component
      def remove_component(entity, component)
        component = component.symbol if component.is_a?(Component)
        remove_component_by_symbol(entity, component)
      end

      # Removes all components associated with the entity
      #
      # @param [Entity] entity
      # @return [void]
      def remove_entity_components(entity)
        @components.each_pair do |comp, entities|
          entities.delete(entity)
        end
      end

      # Adds an entity to the world
      #
      # @param [Entity] entity
      # @return [Entity] Returns the added entity
      private def add_entity(entity)
        @entities << entity
        entity
      end

      # Retrieves an entity object by id
      #
      # @return [Entity, nil]
      def get_entity_by_id(id)
        @entities.find { |e| e.id == id }
      end

      # @param [Entity] entity
      # @return [Entity, nil] returns the deleted entity, or nil if not found
      def remove_entity(entity)
        if e = @entities.delete(entity)
          remove_entity_components e
          e
        end
      end

      # Removes an entity by id
      #
      # @param [String] id
      def remove_entity_by_id(id)
        remove_entity get_entity_by_id(id)
      end

      # Adds a new Entity to the world, an optional prefab can be provided,
      # in which the entity will copy from.
      #
      # @param [Entity] prefab  an entity instance to generate from
      # @return [Entity] a new entity
      def spawn(prefab = nil)
        entity = Entity.new(self)
        entity.copy prefab if prefab
        yield entity if block_given?
        add_entity entity
      end

      # Get Entities for each component and intersect
      #
      # @param [Symbol] syms
      # @yieldparam [Entity] entity
      def filter(*syms, &block)
        return to_enum(:filter, *syms) unless block_given?
        return if syms.empty?
        # retrieve the first list of components, this will be used as the
        # reference list for the remaining symbols.
        sym = syms.shift
        if result = @components[sym].presence
          result.each_key do |e|
            if syms.all? { |s| (l = @components[s]) && l.key?(e) }
              yield e
            end
          end
        end
      end

      ## Systems

      # @param [System]
      def on_system_added(system)
      end

      # Registers a new system, by name or Class
      #
      # @param [Symbol, Class] system_klass
      # @return [System]
      def register(system_klass)
        if system_klass.is_a?(Symbol)
          system = System.manager.fetch(system_klass).new(self)
        else
          system = system_klass.new(self)
        end
        @systems << system
        on_system_added system
        system
      end

      # Update the internal systems
      #
      # @return [self]
      def update(delta)
        @systems.each { |system| system.update delta }
      end

      # Renders the internal systems
      #
      # @return [self]
      def render(x = 0, y = 0, z = 0)
        @systems.each { |system| system.render x, y, z }
      end

      # @return [Hash<Symbol, Object>]
      def to_h
        {
          components: @components,
          entities: @entities,
          systems: @systems
        }
      end

      # @return [Hash<String, Object>] data
      def export
        components = @components.each_with_object({}) do |d, comp_hash|
          component_sym, comps = *d
          entities = comps.each_with_object({}) do |a, hsh|
            eid, comp = *a
            hsh[eid.id] = comp.export
          end
          comp_hash[component_sym.to_s] = entities
        end

        {
          "random"     => @random.export,
          "components" => components,
          "systems"    => @systems.map { |sys| sys.export },
          "entities"   => @entities.map { |entity| entity.export }
        }
      end

      # @param [Hash<String, Object>] data
      # @return [self]
      def import(data)
        clear
        @random = Random.load(data["random"])

        data["entities"].each do |d|
          @entities << Entity.new(self).import(d)
        end

        entity_table = @entities.each_with_object({}) { |e, h| h[e.id] = e }
        data["components"].each_pair do |component_name, comps|
          comp_entities = {}
          comps.each_pair do |entity_id, component|
            if entity = entity_table[entity_id]
              comp_entities[entity] = Moon::EntitySystem::Component.new(component)
            else
              puts "WARN: missing entity (#{entity_id}) present in components"
            end
          end
          @components[component_name.to_sym] = comp_entities
        end

        data["systems"].map do |d|
          @systems << Moon::EntitySystem::System.new(self, d)
        end

        refresh

        self
      end

      # Creates a new World object from the provided data
      #
      # @param [Hash] data
      # @return [World] new world object from data
      def self.load(data)
        new.import data
      end
    end
  end
end
