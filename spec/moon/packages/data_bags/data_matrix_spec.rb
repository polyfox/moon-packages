require 'spec_helper'
require 'data_bags/data_matrix'
require 'std/vector3'
require 'std/rect'

describe Moon::DataMatrix do
  context '#initialize' do
    it 'initializes a DataMatrix' do
      dm = described_class.new(8, 6, 4)
    end

    it 'initializes a DataMatrix with an extra options hash' do
      dm = described_class.new(8, 6, 4, default: 1)
      expect(dm.default).to eq(1)
    end
  end

  context '#[]/=' do
    it 'gets data at the specified coords' do
      src = described_class.new(8, 6, 4, default: 1)
      expect(src[0, 0, 0]).to eq(1)
    end

    it 'sets data at the specified coords' do
      src = described_class.new(8, 6, 4, default: 1)
      expect(src[0, 0, 0]).to eq(1)
      expect(src[0, 0, 1]).to eq(1)

      src[0, 0, 0] = 2
      expect(src[0, 0, 0]).to eq(2)
      expect(src[0, 0, 1]).to eq(1)
    end
  end

  context '#initialize_copy' do
    it 'initializes a copy of the DataMatrix' do
      dm = described_class.new(8, 6, 4, default: 2)
      dest = dm.dup

      expect(dest).not_to equal(dm)
      expect(dest.size).to eq(dm.size)
      expect(dest.xsize).to eq(dm.xsize)
      expect(dest.ysize).to eq(dm.ysize)
      expect(dest.zsize).to eq(dm.zsize)
      expect(dest.blob).to eq(dm.blob)
    end
  end

  context '#resize' do
    it 'shrinks the size of the matrix' do
      src = described_class.new(8, 6, 4, default: 2)
      src.resize(4, 3, 2)

      expect(src.xsize).to eq(4)
      expect(src.ysize).to eq(3)
      expect(src.zsize).to eq(2)

      expect(src.size).to eq(24)
    end

    it 'extends the size of the matrix' do
      src = described_class.new(8, 6, 4, default: 2)
      src.resize(16, 12, 8)

      expect(src.xsize).to eq(16)
      expect(src.ysize).to eq(12)
      expect(src.zsize).to eq(8)

      expect(src.size).to eq(1536)
    end
  end

  context '#iter' do
    it 'can be iterated via its iterator' do
      dm = described_class.new(8, 6, 4, default: 2)
      a = dm.iter.each.to_a
      b = dm.blob

      expect(a).to eq(b)
    end
  end

  context '#sizes' do
    it 'returns the matrix\'s size as a Vector3' do
      src = described_class.new(8, 6, 4, default: 2)
      expect(src.sizes).to eq(Moon::Vector3[8, 6, 4])
    end
  end

  context '#rect' do
    it 'returns a Rect representing the xsize and ysize' do
      src = described_class.new(8, 6, 4, default: 2)
      expect(src.rect).to eq(Moon::Rect[0, 0, 8, 6])
    end
  end

  context '#cuboid' do
    it 'returns a Cuboid representing the xsize, ysize and zsize' do
      src = described_class.new(8, 6, 4, default: 2)
      expect(src.cuboid).to eq(Moon::Cuboid[0, 0, 0, 8, 6, 4])
    end
  end

  context '#to_s' do
    it 'creates a String' do
      dm = described_class.new(8, 6, 4, default: 2)
      # TODO validate string
      dm.to_s
    end
  end

  context 'Serialization' do
    it 'serializes' do
      dm = described_class.new(8, 6, 4, default: 2)
      dest = described_class.load(dm.export)

      expect(dest).not_to equal(dm)
      expect(dest.size).to eq(dm.size)
      expect(dest.xsize).to eq(dm.xsize)
      expect(dest.ysize).to eq(dm.ysize)
      expect(dest.zsize).to eq(dm.zsize)
      expect(dest.blob).to eq(dm.blob)
    end
  end
end
