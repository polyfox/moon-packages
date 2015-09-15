require 'spec_helper'
require 'moon/packages/entity_system/spec_helper'
require 'entity_system/world'

describe Moon::EntitySystem::World do
  let(:world) do
    begin
      w = described_class.new
      w.register :test
      w.spawn { |e| e.add :test }
      w.spawn { |e| e.add :test }
      w
    end
  end

  context '#initialize' do
    it 'initializes a new world' do
      world = described_class.new
    end
  end

  context '#clear' do
    it 'clears the world' do
      w = world.dup
      w.register :test
      w.spawn { |e| e.add :test }
      w.spawn { |e| e.add :test }
      w.clear
    end
  end

  context '#update' do
    it 'updates the world\'s systems' do
      w = world.dup
      w.update(0.15)
    end
  end

  context '#render' do
    it 'renders the world\'s systems' do
      w = world.dup
      w.render(0.15)
    end
  end

  context 'removal' do
    it 'removes entities and their components' do
      w = world.dup
      entity = w.spawn { |e| e.add :test }
      expect(entity.components.size).to eq(1)
      w.remove_component(entity, :test)
      expect(entity.components.size).to eq(0)
      w.remove_entity_by_id(entity.id)
    end
  end

  context 'serialization' do
    it 'exports its data' do
      data = world.export
      expect(data).to include('random')
      expect(data).to include('components')
      expect(data).to include('systems')
      expect(data).to include('entities')
    end

    it 'imports a world data' do
      data = world.export
      described_class.load data
    end
  end
end
