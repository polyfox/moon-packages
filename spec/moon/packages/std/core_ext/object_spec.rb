require 'spec_helper'
require 'std/core_ext/object'
require 'std/core_ext/array'
require 'std/core_ext/hash'
require 'std/core_ext/string'
require 'std/core_ext/nil_class'
require 'std/set'

module Fixtures
  class MyTestObject
    class Point
      attr_accessor :x
      attr_accessor :y

      def initialize(x = 0, y = 0)
        @x = x
        @y = y
      end
    end

    attr_accessor :position

    def initialize
      @position = Point.new
    end
  end
end

describe Object do
  context '#safe_dup' do
    it 'should safely duplicate an object' do
      # numbers are not normally dup-able, so this should touch the rescue branch
      expect(1.safe_dup).to eq(1)
      expect('Foobar'.safe_dup).to eq('Foobar')
    end
  end

  context '#blank?' do
    it 'determines if an object is blank' do
      obj = Object.new
      expect(obj).not_to be_blank
      expect(nil).to be_blank
      expect([]).to be_blank
      expect({}).to be_blank
      expect(Moon::Set.new).to be_blank
      expect('').to be_blank
      expect('     ').to be_blank
      expect("\n \t \r").to be_blank
    end
  end

  context '#present?' do
    it 'determines if an object is present' do
      obj = Object.new
      expect(obj).to be_present
      expect(nil).not_to be_present
      expect([]).not_to be_present
      expect({}).not_to be_present
      expect(Moon::Set.new).not_to be_present
      expect('').not_to be_present
      expect('     ').not_to be_present
      expect("\n \t \r").not_to be_present
    end
  end

  context '#presence' do
    it 'returns the presence of an object' do
      obj = Object.new
      expect(obj.presence).to eq(obj)
      expect([].presence).to eq(nil)
      expect({}.presence).to eq(nil)
      expect(Moon::Set.new.presence).to eq(nil)
      expect(''.presence).to eq(nil)
      expect([1, 2].presence).to eq([1, 2])
      expect({ a: 1 }.presence).to eq(a: 1)
      expect('a'.presence).to eq('a')
    end
  end

  context '#try' do
    it 'should invoke a method on the object' do
      obj = Object.new
      expect(obj.try(:to_s)).to eq(obj.to_s)
      expect(obj.try(:something_that_doesnt_exist)).to eq(nil)
    end
  end

  context '#dotsend' do
    it 'should recursively call into an object' do
      obj = Fixtures::MyTestObject.new
      obj.position.x = 12
      obj.position.y = 2
      # first with a symbol, for regular sends
      expect(obj.dotsend(:position)).to equal(obj.position)
      # then with a dot notation string
      expect(obj.dotsend('position.x')).to eq(obj.position.x)
      # and finally with an array
      expect(obj.dotsend([:position, :y])).to eq(obj.position.y)
    end
  end
end
