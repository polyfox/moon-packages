require 'spec_helper'
require 'moon/packages/entity_system/spec_helper'
require 'entity_system/entity'
require 'entity_system/world'

describe Moon::EntitySystem::Entity do
  context '#initialize' do
    it 'initializes a new entity' do
      world = Moon::EntitySystem::World.new
      entity = described_class.new(world)
    end
  end

  context '#components' do
    it 'returns all components associated with the entity' do
      world = Moon::EntitySystem::World.new
      entity = world.spawn do |e|
        e.add :test
        e.add test_other: { value: 100 }
        e.add Fixtures::EntitySystem::Components::TestPositionComponent.new
      end
      # TODO check components returned

      expect(entity.comp(:test, :test_other).size).to eq(2)
      entity.remove(:test)
    end
  end

  context '#destroy' do
    it 'removes the entity from the world' do
      world = Moon::EntitySystem::World.new
      expect(world.entities).to be_empty
      entity = world.spawn do |e|
        e.add :test
        e.add :test_other
      end
      expect(world.entities).not_to be_empty
      entity.destroy
      expect(world.entities).to be_empty
    end
  end

  context '#copy' do
    it 'copies another entities components' do
      world = Moon::EntitySystem::World.new
      dest = world.spawn
      src = world.spawn do |e|
        e.add :test
        e.add :test_other
      end
      expect(dest.components).to be_empty
      dest.copy(src)
      expect(dest.components).not_to be_empty
    end
  end
end
