require 'spec_helper'
require 'std/aabbcc'

describe Moon::AABBCC do
  context '#initialize' do
    it 'initializes an aabbcc' do
      aabbcc = described_class.new(0, 4)
    end
  end

  context '#intersect?' do
    it 'checks if the aabb intersect with another' do
      aabbcc1 = described_class.new(0, 4)
      aabbcc2 = described_class.new(0, 4)
      aabbcc1.intersect?(aabbcc2)
    end
  end

  context '#&' do
    it 'creates a intersected AABBCC' do
      a = described_class.new([0, 0, 0], 14)
      b = described_class.new([3, 7, 0], 14)
      c = a & b
      expect(c.rad).to eq(Moon::Vector3[-3, -7, 0])
      expect(c.cpos).to eq(Moon::Vector3[-1.5, -3.5, 0])
    end
  end
end
