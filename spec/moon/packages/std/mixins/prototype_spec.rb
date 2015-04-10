require 'std/inflector/core_ext/string'
require 'std/mixins/prototype'

module Fixtures
  class MyPrototypeObject
    class << self
      prototype_attr :thing
      prototype_attr :other_thing
    end

    things << 'Thingy'
    other_things << 'Junk'
  end

  class MyPrototypeObjectSubClass < MyPrototypeObject
    things << 'OtherThingy'
    other_things << 'SomeMoreJunk'
  end
end

describe Fixtures::MyPrototypeObject do
  it 'should have a things class attribute' do
    expect(described_class.things).to eq(['Thingy'])
  end

  it 'should have a each_thing class method' do
    result = []
    described_class.each_thing do |str|
      result << str
    end
    expect(result).to eq(['Thingy'])
  end

  it 'should have a all_things class method' do
    expect(described_class.all_things).to eq(['Thingy'])
  end
end

describe Fixtures::MyPrototypeObjectSubClass do
  it 'its should the thing class attr' do
    expect(described_class.things).to eq(['OtherThingy'])
    expect(described_class.all_things).to eq(['Thingy', 'OtherThingy'])
  end
end
