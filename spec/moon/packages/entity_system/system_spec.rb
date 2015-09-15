require 'spec_helper'
require 'moon/packages/entity_system/spec_helper'
require 'entity_system/system'
require 'entity_system/world'

describe Moon::EntitySystem::System do
  context '#initialize' do
    it 'initializes a new system' do
      world = Moon::EntitySystem::World.new
      sys = described_class.new(world, 'system_name' => 'test')
    end
  end
end
