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

  context '#each_listener' do
    it 'yields all listeners if given no parameters' do
      l = eventable.on(:resize) { |e| }
      eventable.each_listener do |key, cb|
        expect(key).to eq(:resize)
        expect(cb).to eq(l)
      end
    end

    it 'yields listeners of given types' do
      cb1 = eventable.on(:resize) { |e| }
      cb2 = eventable.on(:typing) { |e| }
      cb3 = eventable.on(:press) { |e| }

      eventable.each_listener(:resize) do |key, cb|
        expect(key).to eq(:resize)
        expect(cb).to eq(cb1)
      end

      eventable.each_listener(:typing) do |key, cb|
        expect(key).to eq(:typing)
        expect(cb).to eq(cb2)
      end

      eventable.each_listener(:press) do |key, cb|
        expect(key).to eq(:press)
        expect(cb).to eq(cb3)
      end
    end
  end

  context '#off' do
    it 'unregisters a given listener' do
      eventable.on(:moved) { |e| }
      listener = eventable.on(:resize) { |e| }
      eventable.off(listener)

      # make sure only the :resize callback was removed
      expect(eventable.each_listener(:resize).count).to eq(0)
      # we should have only one listener left now
      expect(eventable.each_listener.count).to eq(1)
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
end
