module Moon
  class World
    attr_reader :entities
    attr_reader :random

    # @components = { ComponentClass => {entity_id => [component, ...], ...}, ...}
    def initialize
      @random = Random.new
      @components = Hash.new { |hash, key| hash[key] = {} } # subkeys always initialized to {}
      @entities = []
      @systems = []
    end

    ##
    # @param [Entity] entity
    def on_entity_added(entity)
      #
    end

    ##
    # @param [Entity] entity
    def on_entity_removed(entity)
      #
    end

    ##
    # @param [Entity] template
    #   @optional
    # @return [Entity]
    def spawn(template=nil)
      entity = Entity.new(self)
      entity.inherit template if template

      @entities << entity

      yield entity if block_given?

      on_entity_added entity

      entity
    end

    ##
    # Get Entities for each component and intersect
    # @param [Array<Symbol>] *syms
    def [](*syms)
      return [] if syms.empty?
      if syms.size == 1
        @components[syms.first].keys
      else
        sym = syms.shift
        result = (@components[sym] || {}).keys
        return [] if result.empty?
        syms.each_with_object(result) do |sym, result|
          result &= @components[sym].keys
        end
      end
    end

    ##
    # @param [Entity] entity
    # @param [Symbol] component_sym
    # @param [Component] component
    # @return [Component]
    private def set_component(entity, component_sym, component)
      #(@components[component_sym][entity] ||= []) << component
      @components[component_sym][entity] = component
      component
    end

    ##
    # @param [Entity] entity
    # @param [Symbol] component_sym
    # @return [Component]
    def get_component(entity, component_sym) # component is class here
      # .first is a hack? return first element, always
      # will be hard when we have more than one component
      # of the same type
      @components[component_sym][entity]
    end

    ##
    # @param [Entity] entity
    # @return [Array<Component>]  components
    def get_components(entity)
      @components.each_with_object([]) do |a, r|
        (key, hash) = *a
        if d = hash[entity]
          r.push(d)
        end
      end
    end

    ##
    # @param [Entity] entity
    # @param [Component] component
    def add_component(entity, component)
      component_sym = component.class.registered
      set_component(entity, component_sym, component)
    end

    ## Systems

    def register(system_klass)
      if system_klass.is_a?(Symbol)
        system = System[system_klass].new(self)
      else
        system = system_klass.new(self)
      end
      @systems << system
    end

    #---

    def update(delta) # parallelize in the future
      for system in @systems
        system.update(delta)
      end
    end

    def to_h
      {
        components: @components,
        entities: @entities,
        systems: @systems
      }
    end

    def export
      components = @components.each_with_object({}) do |d, comp_hash|
        component_sym, comps = *d
        entities = comps.each_with_object({}) do |a, hsh|
          eid, comp = *a
          # entities are exported using their ids
          #hsh[eid.id] = comp.map { |c| c.export }
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

    def import(data)
      @random = Random.load(data["random"])
      entity_table = {}
      @entities = data["entities"].map do |d|
        Entity.new(self).import(d)
      end
      entity_table = @entities.each_with_object({}) { |e, h| h[e.id] = e }
      @components = data["components"].each_with_object({}) do |d, comp_hash|
        component_sym, comps = *d
        entities = comps.each_with_object({}) do |a, hsh|
          eid, comp = *a
          # entities are imported from their ids and then remaped
          #hsh[entity_table[eid]] = comp.map { |c| Component.load(c) }
          hsh[entity_table[eid]] = Component.load(comp)
        end
        comp_hash[component_sym.to_sym] = entities
      end
      @systems = data["systems"].map do |d|
        System.load(d)
      end
      self
    end

    def self.load(data)
      new.import(data)
    end
  end
end
