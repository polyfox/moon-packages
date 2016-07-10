require 'spec_helper'
require 'serializables/vector1'

describe Moon::Vector1 do
  context 'Serialization' do
    it 'serializes' do
      src = described_class.new(12)
      result = described_class.load(src.export)

      expect(result).to eq(src)
    end
  end
end
