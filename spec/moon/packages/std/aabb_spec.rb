require 'spec_helper'
require 'std/aabb'

describe Moon::AABB do
  context '#initialize' do
    it 'initializes an aabb' do
      aabb = described_class.new(0, 4)
    end
  end

  context '#intersect?' do
    it 'checks if the aabb intersect with another' do
      aabb1 = described_class.new(0, 4)
      aabb2 = described_class.new(0, 4)
      aabb1.intersect?(aabb2)
    end
  end
end
