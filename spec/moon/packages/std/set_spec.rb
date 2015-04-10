require 'std/set'

describe Moon::Set do
  context '#initialize' do
    it 'should initialize without parameters' do
      set = Moon::Set.new
    end

    it 'should initialize with parameters' do
      Moon::Set.new([1, 2, 3])
    end
  end

  context '#size' do
    it 'should return the size of the Set (when empty)' do
      set = Moon::Set.new
      expect(set.size).to eq(0)
    end

    it 'should return the size of the Set (with elements)' do
      set = Moon::Set.new([1, 2, 3])
      expect(set.size).to eq(3)
    end
  end

  context '#empty?' do
    it 'should report that the set is empty with no elements' do
      set = Moon::Set.new
      expect(set).to be_empty
    end

    it 'should report that the set is not empty with elements' do
      set = Moon::Set.new([1, 2, 3])
      expect(set).not_to be_empty
    end
  end

  context '#include?' do
    it 'should report that an object exists in the Set' do
      set = Moon::Set.new([1, 2, 3])

      expect(set).to include(1)
      expect(set).not_to include(4)
    end
  end

  context '#each' do
    it 'should yield each element in the Set' do
      set = Moon::Set.new([1, 2, 3])
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
      set = Moon::Set.new([1, 2, 3])
      expect(set).to eq([1, 2, 3])
    end

    it 'should check if a Set is equal to another Set' do
      set1 = Moon::Set.new([1, 2, 3])
      set2 = Moon::Set.new([3, 2, 1])
      expect(set1).to eq(set1)
      expect(set1).to eq(set2)
      expect(set2).to eq(set2)
    end
  end

  context '#clear' do
    it 'should clear the data' do
      set = Moon::Set.new([1, 2, 3])
      expect(set.size).to eq(3)
      set.clear
      expect(set.size).to eq(0)
    end
  end

  context '#add' do
    it 'should add elements to the set' do
      set = Moon::Set.new
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
      set = Moon::Set.new([1, 2, 3])
      set.delete 2
      expect(set).to eq([1, 3])
    end
  end

  context '#concat' do
    it 'should append another set' do
      set1 = Moon::Set.new([1, 2, 3])
      set2 = Moon::Set.new([3, 4, 5])
      set1.concat set2
      # this also tests that the set is unique
      expect(set1).to eq([1, 2, 3, 4, 5])
    end
  end

  context '#sample' do
    it 'should return a random element from the set' do
      set = Moon::Set.new([1, 2, 3, 4])
      expect(set).to include(set.sample)
    end
  end

  context '#pop' do
    it 'should return an element from the set' do
      set = Moon::Set.new([1, 2, 3, 4])
      set.pop
      expect(set.size).to eq(3)
    end
  end

  context '#shift' do
    it 'should return an element from the set' do
      set = Moon::Set.new([1, 2, 3, 4])
      set.shift
      expect(set.size).to eq(3)
    end
  end
end
