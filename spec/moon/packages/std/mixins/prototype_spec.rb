require 'std/inflector/core_ext/string'
require 'std/mixins/prototype'

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

describe MyPrototypeObject do
  it 'should have a things class attribute' do
    expect(MyPrototypeObject.things).to eq(['Thingy'])
  end

  it 'should have a each_thing class method' do
    result = []
    MyPrototypeObject.each_thing do |str|
      result << str
    end
    expect(result).to eq(['Thingy'])
  end

  it 'should have a all_things class method' do
    expect(MyPrototypeObject.all_things).to eq(['Thingy'])
  end
end

describe MyPrototypeObjectSubClass do
  it 'its should the thing class attr' do
    expect(MyPrototypeObjectSubClass.things).to eq(['OtherThingy'])
    expect(MyPrototypeObjectSubClass.all_things).to eq(['Thingy', 'OtherThingy'])
  end
end
