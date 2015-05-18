require 'spec_helper'
require 'std/core_ext/object'
require 'std/core_ext/string'

describe String do
  context '#indent' do
    it 'indents a string' do
      expect('Hello'.indent(2)).to eq('  Hello')
    end

    it 'indents a string with multiple lines' do
      expect("Hello\nWorld\nHow\nAre\nYou".indent(2)).to eq("  Hello\n  World\n  How\n  Are\n  You")
    end
  end
end
