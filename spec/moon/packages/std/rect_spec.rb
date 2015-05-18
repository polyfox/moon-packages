require 'spec_helper'
require 'std/rect'

describe Moon::Rect do
  context '#initialize' do
    it 'initializes a rect' do
      rect = described_class.new(1, 2, 3, 4)
      expect(rect.x).to eq(1)
      expect(rect.y).to eq(2)
      expect(rect.w).to eq(3)
      expect(rect.h).to eq(4)
    end
  end

  context '#split' do
    it 'splits the rect in 4 quadrants' do
      rect = described_class.new(2, 4, 24, 24)
      a, b, c, d = rect.split
    end
  end

  context '#contains?' do
    it 'reports if the rect contains the given point' do
      rect = described_class.new(2, 4, 24, 24)
      expect(rect.contains?(3, 7)).to eq(true)
      expect(rect.contains?(33, 7)).to eq(false)
    end
  end

  context '#to_h' do
  end
end
