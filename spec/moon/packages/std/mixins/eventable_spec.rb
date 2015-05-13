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
      listener = eventable.on(:resize) { |e| }
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
    end

    it 'registers an event given an Event Class' do
      listener = eventable.on(Moon::ResizeEvent) { |e| }
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
    end

    it 'registers an input event with a key' do
      listener = eventable.on(:press, :left)
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
    end

    it 'registers an input event with a list of keys' do
      listener = eventable.on(:press, :left, :a)
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
    end

    it 'registers mulitple events' do
      listeners = eventable.on([:resize, :moved]) { |e| }
      expect(listeners).to be_instance_of(Array)
      expect(listeners.size).to eq(2)
      expect(listeners).to all(be_instance_of(Moon::Eventable::Listener))
    end

    it 'takes a filter as a second parameter' do
      filter = ->(e){ e.action == :press }
      n = 0
      listener = eventable.on(Moon::KeyboardInputEvent, filter) { |e| n += 1 }
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
      eventable.trigger(Moon::KeyboardInputEvent.new(:a, :press, 0))
      eventable.trigger(Moon::KeyboardInputEvent.new(:b, :release, 0))
      expect(n).to eq(1)
    end

    it 'takes a filter as value from the :filter option' do
      filter = ->(e){ e.action == :press }
      n = 0
      listener = eventable.on(Moon::KeyboardInputEvent, filter: filter) { |e| n += 1 }
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
      eventable.trigger(Moon::KeyboardInputEvent.new(:a, :press, 0))
      eventable.trigger(Moon::KeyboardInputEvent.new(:b, :release, 0))
      expect(n).to eq(1)
    end

    it 'creates a filter from given options' do
      n = 0
      listener = eventable.on(Moon::KeyboardInputEvent, action: :press) { |e| n += 1 }
      expect(listener).to be_instance_of(Moon::Eventable::Listener)
      eventable.trigger(Moon::KeyboardInputEvent.new(:a, :press, 0))
      eventable.trigger(Moon::KeyboardInputEvent.new(:b, :release, 0))
      expect(n).to eq(1)
    end
  end

  context '#off' do
    it 'unregisters a given listener' do
      listener = eventable.on(:resize) { |e| }
      eventable.off(listener)
      expect(eventable.each_listener.count).to eq(0)
    end
  end

  context '#trigger' do
    it 'triggers an Event by Symbol' do
      n = 0
      listener = eventable.on(:resize) { |e| n += 1 }
      eventable.trigger Moon::ResizeEvent.new(nil)
      expect(n).to eq(1)
    end

    it 'triggers an Event by class' do
      n = 0
      listener = eventable.on(Moon::ResizeEvent) { |e| n += 1 }
      eventable.trigger Moon::ResizeEvent.new(nil)
      expect(n).to eq(1)
    end
  end

  context '#typing' do
    it 'registers a typing event' do
      n = []
      eventable.typing { |e| n << e }
      eventable.trigger Moon::KeyboardTypingEvent.new('a')
      expect(n.size).to eq(1)
      expect(n[0].char).to eq('a')
    end
  end

  context '#each_listener' do
    it 'iterates all listeners' do
      eventable.on(:press) { |e| }
      eventable.on(:release) { |e| }
      eventable.on(:resize) { |e| }
      eventable.on(Moon::ResizeEvent) { |e| }
      result = []
      values = []
      enum = eventable.each_listener
      expect(enum).to be_instance_of(Enumerator)
      enum.each do |key, value|
        values << value
        result << [key, value]
      end
      expect(result.size).to eq(4)
      expect(values).to all(be_instance_of(Moon::Eventable::Listener))
    end
  end
end
