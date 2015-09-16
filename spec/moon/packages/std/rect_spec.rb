require 'spec_helper'
require 'std/rect'

module Fixtures
  class ObjectWithToRect
    def to_rect
      Moon::Rect.new(2, 4, 6, 8)
    end
  end
end

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

  context '#x2/=' do
    it 'gets the x position for the right side' do
      rect = described_class.new(4, 6, 12, 8)
      expect(rect.x2).to eq(16)
    end

    it 'sets the right-ward x position' do
      rect = described_class.new(4, 6, 12, 8)
      rect.x2 = 20
      expect(rect.x2).to eq(20)
      expect(rect.x).to eq(8)
    end
  end

  context '#y2/=' do
    it 'gets the y position for the right side' do
      rect = described_class.new(4, 6, 12, 8)
      expect(rect.y2).to eq(14)
    end

    it 'sets the right-ward x position' do
      rect = described_class.new(4, 6, 12, 8)
      rect.y2 = 20
      expect(rect.y2).to eq(20)
      expect(rect.y).to eq(12)
    end
  end

  context '#&' do
    it 'creates an intersection rect' do
      a = described_class.new(0, 0, 24, 24)
      b = described_class.new(12, 8, 24, 24)

      c = a & b
      expect(c.to_a).to eq([12, 8, 12, 16])
    end
  end

  context '#split' do
    it 'splits the rect in 4 quadrants' do
      rect = described_class.new(2, 4, 24, 24)
      a, b, c, d = rect.split
      expect(a.to_a).to eq([ 2,  4, 12, 12])
      expect(b.to_a).to eq([14,  4, 12, 12])
      expect(c.to_a).to eq([ 2, 16, 12, 12])
      expect(d.to_a).to eq([14, 16, 12, 12])
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
    it 'returns a Rect\'s parameters as a Hash' do
      rect = described_class.new(2, 4, 24, 32)
      expect(rect.to_h).to eq({ x: 2, y: 4, w: 24, h: 32 })
    end
  end

  context '#empty?' do
    it 'determines if a Rect is empty' do
      rect = described_class.new
      expect(rect).to be_empty

      rect.w = 32
      expect(rect).to be_empty

      rect.w = 0
      rect.h = 32
      expect(rect).to be_empty

      rect.w = 32
      expect(rect).not_to be_empty
    end
  end

  context '#translate' do
    it 'translates the Rect by the given position' do
      rect = described_class.new(0, 0, 24, 24)
      result = rect.translate(6, 8)
      expect(result.to_a).to eq([6, 8, 24, 24])
    end
  end

  context '#translatef' do
    it 'translates the Rect by the given rate' do
      rect = described_class.new(0, 0, 24, 24)
      result = rect.translatef(0.5, 0.25)
      expect(result.to_a).to eq([12, 6, 24, 24])
    end
  end

  context '#scale' do
    it 'scales the Rect by the given scales' do
      rect = described_class.new(0, 0, 6, 6)
      result = rect.scale(4, 4)
      expect(result.to_a).to eq([0, 0, 24, 24])
    end
  end

  context '.[]' do
    it 'converts an object to Rect' do
      expected = [2, 4, 6, 8]
      src = described_class.new(2, 4, 6, 8)
      rect = described_class[src]
      expect(rect).to equal(src)

      rect = described_class[Fixtures::ObjectWithToRect.new]
      expect(rect.to_a).to eq(expected)

      rect = described_class[2, 4, 6, 8]
      expect(rect.to_a).to eq(expected)

      rect = described_class[[2, 4, 6, 8]]
      expect(rect.to_a).to eq(expected)

      rect = described_class[[Moon::Vector2.new(2, 4), Moon::Vector2.new(6, 8)]]
      expect(rect.to_a).to eq(expected)

      rect = described_class[x: 2, y: 4, w: 6, h: 8]
      expect(rect.to_a).to eq(expected)

      rect = described_class[14]
      expect(rect.to_a).to eq([0, 0, 14, 14])

      rect = described_class[Moon::Vector2.new(12, 14)]
      expect(rect.to_a).to eq([0, 0, 12, 14])

      rect = described_class[Moon::Vector4.new(2, 4, 6, 8)]
      expect(rect.to_a).to eq(expected)
    end

    it 'will not accept an oversized or undersized array' do
      expect { described_class[[0]] }.to raise_error(ArgumentError)
      expect { described_class[[0, 1, 2, 3, 4]] }.to raise_error(ArgumentError)
    end

    it 'will not convert an object' do
      expect { described_class[Object.new] }.to raise_error(TypeError)
    end
  end
end
