require 'spec_helper'
require 'std/vector1'

describe Moon::Vector1 do
  context '#sum' do
    it 'adds its properties' do
      src = described_class.new(2)
      expect(src.sum).to eq(2)
    end
  end

  context '#zero?' do
    it 'determines if the vector is 0' do
      src = described_class.new(2)
      expect(src).not_to be_zero

      src = described_class.new(0)
      expect(src).to be_zero
    end
  end

  context '#to_h' do
    it 'returns a Hash with the properties' do
      src = described_class.new(2)
      expect(src.to_h).to eq(x: 2)
    end
  end

  context '#to_s' do
    it 'returns a String' do
      src = described_class.new(2)
      expect(src.to_s).to eq('2.0')
    end
  end

  context '#[]/=' do
    it 'gets a property by name or index' do
      src = described_class.new(2)
      expect(src[0]).to eq(2)
      expect(src['x']).to eq(2)
      expect(src[:x]).to eq(2)
    end

    it 'sets a property by name or index' do
      src = described_class.new(2)
      expect(src.x).to eq(2)

      src[0] = 4
      expect(src.x).to eq(4)

      src['x'] = 8
      expect(src.x).to eq(8)

      src[:x] = 16
      expect(src.x).to eq(16)
    end
  end

  context '#abs' do
    it 'returns an abs Vector1' do
      v = described_class.new(-1)
      result = v.abs
      expect(result.x).to eq(1)
    end
  end

  context 'Serialization' do
    it 'serializes' do
      src = described_class.new(12)
      result = described_class.load(src.export)

      expect(result).to eq(src)
    end
  end
end
