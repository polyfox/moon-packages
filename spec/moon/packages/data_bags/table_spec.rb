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
end
