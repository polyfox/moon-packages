require 'spec_helper'
require 'std/set'

describe Moon::Set do
  context '#initialize' do
    it 'should initialize without parameters' do
      set = described_class.new
    end

    it 'should initialize with parameters' do
      described_class.new([1, 2, 3])
    end

    it 'initializes given a block' do
      actual = described_class.new(6) { |i| 6 - i }
      expect(actual).to eq([6, 5, 4, 3, 2, 1])
    end
  end

  context '#to_a' do
    it 'returns the set as an Array' do
      actual = described_class.new([1, 2, 3, 4, 5, 6]).to_a
      expect(actual).to eq([1, 2, 3, 4, 5, 6])
    end
  end

  context '#size' do
    it 'should return the size of the Set (when empty)' do
      set = described_class.new
      expect(set.size).to eq(0)
    end

    it 'should return the size of the Set (with elements)' do
      set = described_class.new([1, 2, 3])
      expect(set.size).to eq(3)
    end
  end

  context '#empty?' do
    it 'should report that the set is empty with no elements' do
      set = described_class.new
      expect(set).to be_empty
    end

    it 'should report that the set is not empty with elements' do
      set = described_class.new([1, 2, 3])
      expect(set).not_to be_empty
    end
  end

  context '#include?' do
    it 'should report that an object exists in the Set' do
      set = described_class.new([1, 2, 3])

      expect(set).to include(1)
      expect(set).not_to include(4)
    end
  end

  context '#each' do
    it 'should yield each element in the Set' do
      set = described_class.new([1, 2, 3])
      got = []
      set.each do |e|
        expect(e).to be_kind_of(Integer)
        got << e
      end
      expect(got.size).to eq(3)
      expect(got.all? { |e| set.include?(e) }).to eq(true)
    end
  end

  context '#==' do
    it 'should check if a Set is equal to an Array' do
      set = described_class.new([1, 2, 3])
      expect(set).to eq([1, 2, 3])
    end

    it 'should check if a Set is equal to another Set' do
      set1 = described_class.new([1, 2, 3])
      set2 = described_class.new([3, 2, 1])
      expect(set1).to eq(set1)
      expect(set1).to eq(set2)
      expect(set2).to eq(set2)
      expect(set2).not_to eq(nil)
    end
  end

  context '#clear' do
    it 'should clear the data' do
      set = described_class.new([1, 2, 3])
      expect(set.size).to eq(3)
      set.clear
      expect(set.size).to eq(0)
    end
  end

  context '#add' do
    it 'should add elements to the set' do
      set = described_class.new
      set.add 2
      expect(set.size).to eq(1)
      expect(set).to include(2)
      set.add 3, 4
      expect(set.size).to eq(3)
      expect(set).to include(3)
      expect(set).to include(4)
    end
  end

  context '#delete' do
    it 'should remove an element from the set' do
      set = described_class.new([1, 2, 3])
      set.delete 2
      expect(set).to eq([1, 3])
    end
  end

  context '#concat' do
    it 'should append another set' do
      set1 = described_class.new([1, 2, 3])
      set2 = described_class.new([3, 4, 5])
      set1.concat set2
      # this also tests that the set is unique
      expect(set1).to eq([1, 2, 3, 4, 5])
    end
  end

  context '#sample' do
    it 'should return a random element from the set' do
      set = described_class.new([1, 2, 3, 4])
      expect(set).to include(set.sample)
    end
  end

  context '#pop' do
    it 'should return an element from the set' do
      set = described_class.new([1, 2, 3, 4])
      set.pop
      expect(set.size).to eq(3)
    end
  end

  context '#shift' do
    it 'should return an element from the set' do
      set = described_class.new([1, 2, 3, 4])
      set.shift
      expect(set.size).to eq(3)
    end
  end
end
