require 'spec_helper'
require 'micro_json/micro_json'

module Fixtures
  class JsonDumpableObject
    def to_json
      MicroJSON.dump({1 => 2})
    end
  end

  class JsonUndumpableObject
    undef_method :to_json if method_defined?(:to_json)
  end
end

describe MicroJSON do
  context '#dump' do
    it 'dumps an object as JSON' do
      expect(described_class.dump(1)).to eq('1')
      expect(described_class.dump(1.0)).to eq('1.0')
      expect(described_class.dump('Hello, World')).to eq('"Hello, World"')
      expect(described_class.dump(:json)).to eq('"json"')
      expect(described_class.dump(:json, symbols: true)).to eq('":json"')
      expect(described_class.dump(true)).to eq('true')
      expect(described_class.dump(false)).to eq('false')
      expect(described_class.dump(nil)).to eq('null')
      expect(described_class.dump([1, 2.0, '3'])).to eq('[1,2.0,"3"]')
      expect(described_class.dump({'a' => 1, 'bee' => 1.0, 'cea' => 'Hello, World', 'dee' => true, 'e' => [1,2.0,'3']})).to eq('{"a":1,"bee":1.0,"cea":"Hello, World","dee":true,"e":[1,2.0,"3"]}')
      expect(described_class.dump(Fixtures::JsonDumpableObject.new)).to eq('{"1":2}')
    end

    it 'fails if the object could not be dumped with any known method' do
      expect { described_class.dump(Fixtures::JsonUndumpableObject.new) }.to raise_error(TypeError)
    end
  end

  context '#load' do
    it 'loads an object from JSON' do
      expect(described_class.load('// This is a comment')).to eq(nil)
      expect(described_class.load('1')).to eq(1)
      expect(described_class.load('-2')).to eq(-2)
      expect(described_class.load('1.0')).to eq(1.0)
      expect(described_class.load('0xF')).to eq(15)
      expect(described_class.load('0xFF')).to eq(255)
      expect(described_class.load('"Hello, World"')).to eq('Hello, World')
      expect(described_class.load('":json"', symbols: true)).to eq(:json)
      expect(described_class.load('true')).to eq(true)
      expect(described_class.load('false')).to eq(false)
      expect(described_class.load('null')).to eq(nil)
      expect(described_class.load('[1,2,3]')).to eq([1,2,3])
      expect(described_class.load('{"a":"b","c":1,"d":[1,2,3]}')).to eq("a" => "b", "c" => 1, "d" => [1, 2, 3])
    end

    context 'failure conditions' do
      it 'fails if given hex-values in a non-hex number' do
        expect { described_class.load('1A') }.to raise_error(MicroJSON::Decoder::UnexpectedChar)
      end

      it 'fails if given hex-values in a float number' do
        expect { described_class.load('1.AF') }.to raise_error(MicroJSON::Decoder::UnexpectedChar)
      end

      it 'fails if given floating point in a hex number' do
        expect { described_class.load('0x12.A') }.to raise_error(MicroJSON::Decoder::InvalidNumeric)
      end
    end
  end
end
