require 'std/core_ext/random'

describe Random do
  subject(:rnd) { Random.random }

  it 'can generate a random Integer' do
    expect(rnd.int(10)).to be_a_kind_of(Integer)
  end

  it 'can sample an array' do
    ary = [1, 2, 3, 4, 5]
    expect(ary).to include(rnd.sample(ary))
  end

  it 'can generate binary strings' do
    str = rnd.binary(16)
    expect(str.length).to eq(16)
    expect(str).to match(/\A[01]+\z/)
  end

  it 'can generate octal strings' do
    str = rnd.octal(16)
    expect(str.length).to eq(16)
    expect(str).to match(/\A[01234567]+\z/)
  end

  it 'can generate hexa-decimal strings' do
    str = rnd.hex(16)
    expect(str.length).to eq(16)
    expect(str).to match(/\A[0123456789ABCDEF]+\z/)
  end

  it 'can generate base64 strings' do
    str = rnd.base64(16)
    expect(str.length).to eq(16)
    expect(str).to match(/\A[0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ\+\-]+\z/i)
  end

  it 'can return its settings as a Hash' do
    hsh = rnd.to_h
    expect(hsh).to include(:seed)
    expect(hsh[:seed]).to eq(rnd.seed)
  end

  it 'can load a Random from a export-ed Hash' do
    data = rnd.export
    rnd2 = Random.load data
    expect(rnd2.seed).to eq(rnd.seed)
  end
end
