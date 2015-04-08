require 'std/core_ext/object'
require 'std/core_ext/hash'

describe Hash do
  context '#has_slice?' do
    it 'checks if the Hash includes a slice' do
      slce = { a: 2, b: 3 }
      hsh = { a: 2, b: 3, c: 4 }
      expect(hsh.has_slice?(slce)).to eq(true)
    end
  end

  context '#slice' do
    it 'creates a new hash ' do
      hsh = { a: 2, b: 3, c: 4 }
      slce = hsh.slice(:a, :b, :d)
      expect(slce).to eq(a: 2, b: 3, d: nil)
    end
  end

  context '#fetch_multi' do
    it 'gets existing values by key' do
      hsh = { a: 2, b: 3, c: 4 }
      expect(hsh.fetch_multi(:a, :b)).to eq([2, 3])
    end

    it 'should raise an erro if a key doesn\'t exist' do
      hsh = { a: 2, b: 3, c: 4 }
      expect { hsh.fetch_multi(:a, :b, :d) }.to raise_error(KeyError)
    end
  end

  context '#blank?' do
    it 'should be blank, if its empty?' do
      expect({}.blank?).to eq(true)
    end

    it 'should not be blank, if it has elements' do
      expect({ a: 1 }.blank?).to eq(false)
    end
  end

  context '#exclude' do
    it 'creates a new hash without the given keys' do
      hsh = { a: 2, b: 3, c: 4 }
      result = hsh.exclude :c, :b
      expect(result).to eq(a: 2)
    end
  end

  context '#permit' do
    it 'creates a new hash with only the given keys' do
      hsh = { a: 2, b: 3, c: 4 }
      result = hsh.permit :b, :c, :d
      expect(result).to eq(b: 3, c: 4)
    end
  end

  context '#remap' do
    it 'creates a new Hash with keys changed' do
      hsh = { a: 2, b: 3, c: 4 }
      result = hsh.remap { |key| key.to_s.upcase.to_sym }
      expect(result).to eq(A: 2, B: 3, C: 4)
    end
  end

  context '#symbolize_keys' do
    it 'creates a new Hash with keys as Symbols' do
      hsh = { 'a' => 2, 'bash' => 'script', 'centaur' => 'myth' }
      result = hsh.symbolize_keys
      expect(result).to eq(a: 2, bash: 'script', centaur: 'myth')
    end
  end

  context '#stringify_keys' do
    it 'creates a new Hash with keys as Strings' do
      hsh = { a: 2, b: 'bee', c: :SEA }
      result = hsh.stringify_keys
      expect(result).to eq('a' => 2, 'b' => 'bee', 'c' => :SEA)
    end
  end
end
