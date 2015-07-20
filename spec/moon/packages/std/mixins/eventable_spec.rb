require 'spec_helper'
require 'std/mixins/eventable'

module Fixtures
  class EventableTestObject
    include Moon::Eventable

    def initialize
      initialize_eventable
    end
  end
end

describe Moon::Eventable do
  subject(:eventable) { @eventable ||= Fixtures::EventableTestObject.new }

  context '#on' do
    it 'registers an event given a Symbol' do
      eventable.on(:resize) { |e| }
    end
  end

  context '#trigger' do
    it 'triggers an event' do
      n, m = 0, 0
      eventable.on(:any) do |e|
        expect(e).to be_instance_of(Moon::Event)
        n += 1
      end

      eventable.on(:press) do |e|
        expect(e).to be_instance_of(Moon::Event)
        expect(e.type).to eq(:press)
        m += 1
      end

      eventable.trigger Moon::Event.new(:press)
      eventable.trigger Moon::Event.new(:release)

      expect(n).to eq(2)
      expect(m).to eq(1)
    end
  end

  context '#typing' do
    it 'registers a typing event' do
      n = 0
      eventable.typing do |e|
        expect(e).to be_instance_of(Moon::Event)
        n += 1
      end
      eventable.trigger Moon::Event.new(:typing)
      expect(n).to eq(1)
    end
  end

  context '#off' do
    it 'unregisters a given listener' do
      eventable.on(:moved) { |e| }
      n = 0
      listener = eventable.on(:resize) { |e| n += 1 }

      # increment the counter once
      eventable.trigger(Moon::Event.new(:resize))
      expect(n).to eq(1)

      # now remove the listener and try to increment again
      eventable.off(listener)
      eventable.trigger(Moon::Event.new(:resize))
      expect(n).to eq(1)
    end
  end

end
