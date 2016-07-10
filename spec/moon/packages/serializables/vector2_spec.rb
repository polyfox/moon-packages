require 'spec_helper'
require 'serializables/vector2'

describe Moon::Vector2 do
  context 'Serialization' do
    it 'serializes' do
      src = described_class.new(2, 3)
      expect(described_class.load(src.export)).to eq(described_class[2, 3])
    end
  end
end
