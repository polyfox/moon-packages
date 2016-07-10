require 'spec_helper'
require 'serializables/vector3'

describe Moon::Vector3 do
  context 'Serialization' do
    it 'serializes' do
      src = described_class.new(12, 8, 4)
      result = described_class.load(src.export)

      expect(result).to eq(src)
    end
  end
end
