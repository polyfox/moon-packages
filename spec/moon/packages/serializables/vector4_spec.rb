require 'spec_helper'
require 'serializables/vector4'

describe Moon::Vector4 do
  context 'Serialization' do
    it 'serializes' do
      src = described_class.new(12, 8, 4, 2)
      result = described_class.load(src.export)

      expect(result).to eq(src)
    end
  end
end
