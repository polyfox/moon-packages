require 'spec_helper'
require 'std/aabb'
require 'std/vector2'

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
      # this really should be "to be_intersecting", but uuuuuuugggh
      expect(aabb1).to be_intersect(aabb2)
    end
  end

  context '#&' do
    it 'creates an intersecting AABB' do
      a = described_class.new(0, 4)
      b = described_class.new([2, 2], 4)

      c = a & b

      expect(c.cpos).to eq(Moon::Vector2[1, 1])
      expect(c.rad).to eq(Moon::Vector2[2, 2])
    end
  end

  context '.create_encompassing' do
    it 'creates an encompassing AABB from the given AABBs' do
      aabbs = [
        described_class.new([2, 2], 4),
        described_class.new([-2, -2], 4)
      ]
      result = described_class.create_encompassing(aabbs)

      expect(result.cpos).to eq(Moon::Vector2[0, 0])
      expect(result.rad).to eq(Moon::Vector2[6, 6])
    end
  end
end
