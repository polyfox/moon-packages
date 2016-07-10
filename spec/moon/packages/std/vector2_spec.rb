require 'spec_helper'
require 'std/vector2'

describe Moon::Vector2 do
  context '#sum' do
    it 'calculates the sum of all properties in the vector' do
      src = described_class.new(2, 4)
      expect(src.sum).to eq(6)
    end
  end

  context '#zero?' do
    it 'determines if a vector is zero or not' do
      src = described_class.new(2, 4)
      expect(src).not_to be_zero

      src = described_class.new(0, 0)
      expect(src).to be_zero
    end
  end

  context '#xy/=' do
    it 'returns itself' do
      src = described_class.new(2, 4)
      expect(src.xy).to equal(src)
    end

    it 'sets the xy properties of the vector' do
      src = described_class.new(2, 4)
      src.xy = [4, 6]
      expect(src.xy).to eq(described_class.new(4, 6))
    end
  end

  context '#to_s' do
    it 'returns a String' do
      src = described_class.new(2, 4)
      expect(src.to_s).to eq('2.0,4.0')
    end
  end

  context '#to_h' do
    it 'returns a Hash' do
      src = described_class.new(2, 4)
      expect(src.to_h).to eq(x: 2.0, y: 4.0)
    end
  end

  context '#[]/=' do
    it 'accesses the vector\'s property by name, or index' do
      src = described_class.new(2, 4)

      expect(src[0]).to eq(2)
      expect(src['x']).to eq(2)
      expect(src[:x]).to eq(2)

      expect(src[1]).to eq(4)
      expect(src['y']).to eq(4)
      expect(src[:y]).to eq(4)
    end

    it 'sets the vector\'s property by name, or index' do
      src = described_class.new(0, 0)
      src[0] = 2
      src[1] = 4
      expect(src.x).to eq(2)
      expect(src.y).to eq(4)

      src['x'] = 4
      src['y'] = 6
      expect(src.x).to eq(4)
      expect(src.y).to eq(6)

      src[:x] = 6
      src[:y] = 8
      expect(src.x).to eq(6)
      expect(src.y).to eq(8)
    end
  end

  context '#round' do
    it 'returns a rounded vector' do
      src = described_class.new(0.6, 0.4)

      expect(src.round).to eq(described_class[1.0, 0.0])
    end
  end

  context '#floor' do
    it 'returns a floored vector' do
      src = described_class.new(2.6, 1.4)

      expect(src.floor).to eq(described_class[2.0, 1.0])
    end
  end

  context '#ceil' do
    it 'returns a ceiled vector' do
      src = described_class.new(2.6, 1.4)

      expect(src.ceil).to eq(described_class[3.0, 2.0])
    end
  end

  context '#abs' do
    it 'returns an abs vector' do
      src = described_class.new(-2, -4)

      expect(src.abs).to eq(described_class[2, 4])
    end
  end

  context '#perp' do
    it 'returns a perpendicular vector' do
      src = described_class.new(2, 4)

      expect(src.perp).to eq(described_class[-4, 2])
    end
  end

  context '#rperp' do
    it 'returns a reversed perpendicular vector' do
      src = described_class.new(2, 4)

      expect(src.rperp).to eq(described_class[4, -2])
    end
  end

  # forgot to implement dot in the mock classes
  #context '#lengthsq' do
  #  it 'returns its squared length' do
  #    src = described_class.new(2, 4)
  #    expect(src.lengthsq).to eq(64)
  #  end
  #end

  context '.zero' do
    it 'returns a zero vector' do
      expect(described_class.zero).to eq(described_class[0, 0])
    end
  end
end
