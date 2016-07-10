require 'spec_helper'
require 'std/vector2'
require 'std/vector3'

describe Moon::Vector3 do
  context '#sum' do
    it 'sums all the properties of the vector' do
      src = described_class.new(2, 4, 6)
      expect(src.sum).to eq(12)
    end
  end

  context '#zero?' do
    it 'determines if the vector is a zero vector' do
      src = described_class.new(2, 4, 6)
      expect(src).not_to be_zero

      src = described_class.new(2, 4, 0)
      expect(src).not_to be_zero

      src = described_class.new(0, 0, 0)
      expect(src).to be_zero
    end
  end

  context '#xy/=' do
    it 'returns the x and y properties as a Vector2' do
      src = described_class.new(2, 4, 6)
      expect(src.xy).to eq(Moon::Vector2[2, 4])
    end

    it 'sets the x and y properties' do
      src = described_class.new(2, 4, 6)
      src.xy = [8, 12]
      expect(src.xy).to eq(Moon::Vector2[8, 12])
    end
  end

  context '#xyz/=' do
    it 'returns itself' do
      src = described_class.new(2, 4, 6)
      expect(src.xyz).to equal(src)
    end

    it 'sets its x, y and z properties' do
      src = described_class.new(2, 4, 6)
      src.xyz = [4, 6, 8]
      expect(src.xyz).to eq(described_class[4, 6, 8])
    end
  end

  context '#to_s' do
    it 'returns a String' do
      src = described_class.new(2, 4, 6)
      expect(src.to_s).to eq('2.0,4.0,6.0')
    end
  end

  context '#to_h' do
    it 'returns a Hash with all its properties' do
      src = described_class.new(2, 4, 6)
      expect(src.to_h).to eq(x: 2, y: 4, z: 6)
    end
  end

  context '#[]/=' do
    it 'gets a property by name, or index' do
      src = described_class.new(2, 4 ,6)
      expect(src[0]).to eq(2)
      expect(src[1]).to eq(4)
      expect(src[2]).to eq(6)

      expect(src['x']).to eq(2)
      expect(src['y']).to eq(4)
      expect(src['z']).to eq(6)

      expect(src[:x]).to eq(2)
      expect(src[:y]).to eq(4)
      expect(src[:z]).to eq(6)
    end

    it 'sets a property by name, or index' do
      src = described_class.new(2, 4 ,6)
      src[0] = 12
      src[1] = 24
      src[2] = 36

      expect(src[0]).to eq(12)
      expect(src[1]).to eq(24)
      expect(src[2]).to eq(36)

      src['x'] = 8
      src['y'] = 16
      src['z'] = 24

      expect(src['x']).to eq(8)
      expect(src['y']).to eq(16)
      expect(src['z']).to eq(24)

      src[:x] = 4
      src[:y] = 8
      src[:z] = 12

      expect(src[:x]).to eq(4)
      expect(src[:y]).to eq(8)
      expect(src[:z]).to eq(12)
    end
  end

  context '#round' do
    it 'returns a rounded vector' do
      src = described_class.new(0.6, 0.4, 2.2)

      expect(src.round).to eq(described_class[1.0, 0.0, 2.0])
    end
  end

  context '#floor' do
    it 'returns a floored vector' do
      src = described_class.new(2.6, 1.4, 3.9)

      expect(src.floor).to eq(described_class[2.0, 1.0, 3.0])
    end
  end

  context '#ceil' do
    it 'returns a ceiled vector' do
      src = described_class.new(2.6, 1.4, 3.1)

      expect(src.ceil).to eq(described_class[3.0, 2.0, 4.0])
    end
  end

  context '#abs' do
    it 'returns an abs vector' do
      src = described_class.new(-2, -4, 3)

      expect(src.abs).to eq(described_class[2, 4, 3])
    end
  end

  context '.zero' do
    it 'returns a zero vector' do
      result = described_class.zero
      expect(result).to eq(described_class[0, 0, 0])
    end
  end
end
