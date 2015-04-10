require 'std/core_ext/module'

module Fixtures
  module MyEnums
    enum_const :NULL, :ONE, :TWO, :THREE
    enum_const NOPE: 0, MAYBE: 1, YUP: 2
  end
end

describe Module do
  context '#enum_const' do
    it 'should have defined each symbol as a constant' do
      expect(Fixtures::MyEnums::NULL).to eq(0)
      expect(Fixtures::MyEnums::ONE).to eq(1)
      expect(Fixtures::MyEnums::TWO).to eq(2)
      expect(Fixtures::MyEnums::THREE).to eq(3)

      expect(Fixtures::MyEnums::NOPE).to eq(0)
      expect(Fixtures::MyEnums::MAYBE).to eq(1)
      expect(Fixtures::MyEnums::YUP).to eq(2)
    end
  end
end
