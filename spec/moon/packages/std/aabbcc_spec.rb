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
end
