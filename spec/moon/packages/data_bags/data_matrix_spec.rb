require 'spec_helper'
require 'data_bags/data_matrix'

describe Moon::DataMatrix do
  context '#initialize' do
    it 'initializes a data matrix' do
      dm = described_class.new(8, 6, 4)
    end

    it 'initializes a data matrix with an extra options hash' do
      dm = described_class.new(8, 6, 4, default: 1)
      expect(dm.default).to eq(1)
    end
  end
end
