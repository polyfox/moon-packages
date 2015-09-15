require 'spec_helper'
require 'std/core_ext/object'
require 'entity_system/system'
require 'entity_system/component'

module Fixtures
  module EntitySystem
    module Systems
      class TestSystem
        include Moon::EntitySystem::System

        register :test

        def update(delta)
          world.filter :test do |e|
            e[:test].value += 1
          end
        end
      end
    end

    module Components
      class TestComponent
        include Moon::EntitySystem::Component

        register :test

        field :value, type: Integer, default: 0
      end

      class TestOtherComponent
        include Moon::EntitySystem::Component

        register :test_other

        field :value, type: Integer, default: 0
      end

      class TestPositionComponent
        include Moon::EntitySystem::Component

        register :pos

        field :x, type: Integer, default: 0
        field :y, type: Integer, default: 0
      end
    end
  end
end
