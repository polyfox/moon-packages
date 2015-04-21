require 'spec_helper'
require 'std/core_ext/integer'

describe Integer do
  context '#pred' do
    it 'should return the preceeding integer' do
      expect(1.pred).to eq(0)
    end
  end

  context '#round' do
    it 'should round the integer' do
      expect(1.round(2)).to eq(1.0)
    end
  end

  context '#masked?' do
    it 'should check if bits are set' do
      expect(0.masked?(0)).to eq(true)
      expect(0b111001.masked?(0b1)).to eq(true)
      expect(0b111001.masked?(0b10)).to eq(false)
    end
  end
end
