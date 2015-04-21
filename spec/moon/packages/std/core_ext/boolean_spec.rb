require 'spec_helper'
require 'std/core_ext/object'
require 'std/core_ext/boolean'
require 'std/core_ext/true_class'
require 'std/core_ext/false_class'

describe Boolean do
  context '#to_bool' do
    it 'should convert a object to a Boolean' do
      expect(true.to_bool).to eq(true)
      expect(false.to_bool).to eq(false)
    end
  end
end

describe FalseClass do
  it 'has no presence' do
    expect(false.presence).to be_nil
  end

  it 'is blank' do
    expect(false.blank?).to eq(true)
  end
end

describe TrueClass do
  it 'has a presence of itself' do
    expect(true.presence).to eq(true)
  end

  it 'is not blank' do
    expect(true.blank?).to eq(false)
  end
end
