require 'spec_helper'
require 'data_bags/table'

describe Moon::Table do
  context '#initialize' do
    it 'initializes a table' do
      dm = described_class.new(8, 6)
      expect(dm[0, 0]).to eq(0)
      expect(dm.default).to eq(0)
    end

    it 'initializes a table with an extra options hash' do
      dm = described_class.new(8, 6, default: 1)
      expect(dm[0, 0]).to eq(1)
      expect(dm.default).to eq(1)
    end
  end

  context '#initialize_copy' do
    it 'initializes a copy of the table' do
      src = described_class.new(8, 6, default: 2)
      result = src.dup
      expect(result).not_to equal(src)
      expect(result.blob).to eq(src.blob)
    end
  end

  context '#*_by_index' do
    it 'gets an entry by index' do
      src = described_class.new(8, 6, default: 2)
      src[0, 0] = 0
      expect(src.get_by_index(0)).to eq(0)
      expect(src.get_by_index(1)).to eq(2)
    end

    it 'sets an entry by index' do
      src = described_class.new(8, 6, default: 2)
      src.set_by_index(0, 0)
      expect(src[0, 0]).to eq(0)
      expect(src[0, 1]).to eq(2)
    end
  end

  context '#resize' do
    it 'shrinks the size of a table' do
      src = described_class.new(8, 6, default: 2)
      src.resize(4, 3)
      expect(src.xsize).to eq(4)
      expect(src.ysize).to eq(3)
    end

    it 'expands the size of a table' do
      src = described_class.new(8, 6, default: 2)
      src.resize(16, 12)
      expect(src.xsize).to eq(16)
      expect(src.ysize).to eq(12)
    end
  end

  context 'Serialization' do
    it 'exports and imports a table' do
      src = described_class.new(8, 6, default: 2)
      dest = described_class.load(src.export)

      expect(dest.size).to eq(src.size)
      expect(dest.xsize).to eq(src.xsize)
      expect(dest.ysize).to eq(src.ysize)
      expect(dest.blob).to eq(src.blob)
    end
  end

  context '#to_s' do
    it 'creates a string from the data' do
      src = described_class.new(8, 6, default: 2)
      # TODO: validate output
      src.to_s
    end
  end
end
