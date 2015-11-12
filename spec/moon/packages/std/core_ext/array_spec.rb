require 'spec_helper'
require 'std/core_ext/object'
require 'std/core_ext/array'
require 'std/core_ext/array/dig'
require 'std/core_ext/hash/dig'

describe Array do
  context '#dig' do
    it 'can dig through an Array of Arrays' do
      data = [
        [:first, [0, 1, 2]],
        [:second, [3, 4, 5]]
      ]
      expect(data.dig(0)).to eq([:first, [0, 1, 2]])
      expect(data.dig(0, 0)).to eq(:first)
      expect(data.dig(1, 0)).to eq(:second)
      expect(data.dig(1, 1)).to eq([3, 4, 5])
      expect(data.dig(1, 1, 0)).to eq(3)
    end

    it 'can dig through an Array of Diggables' do
      data = [
        { first_name: 'John', last_name: 'Doe' },
        { first_name: 'Foo', last_name: 'Bar' }
      ]

      expect(data.dig(0, :first_name)).to eq('John')
      expect(data.dig(1, :last_name)).to eq('Bar')
    end
  end

  context '#blank?' do
    it 'should report being blank, if the Array is empty?' do
      expect([].blank?).to eq(true)
    end

    it 'should report being none-blank, if the Array is has elements' do
      expect([nil].blank?).to eq(false)
    end
  end

  context '#singularize' do
    it 'should return its element if it only has 1 element' do
      expect([1].singularize).to eq(1)
    end

    it 'should return self if it has more than 1 element' do
      obj = [1, 2, 3]
      expect(obj.singularize).to equal(obj)
    end
  end

  # this will test the ruby one most likely though.
  context '#sort_by!' do
    it 'should sort by value from the block' do
      ary = ['<3', 'Egg', 'I', 'BlahDeDaaah']
      ary.sort_by! { |s| s.length }
      expect(ary).to eq(['I', '<3', 'Egg', 'BlahDeDaaah'])
    end
  end

  context '#prepend' do
    it 'should add an element to the beginning of the Array' do
      ary = [2, 3]
      ary.prepend 1
      expect(ary).to eq([1, 2, 3])
    end
  end

  context '#append' do
    it 'should add an element to the end of the Array' do
      ary = [2, 3]
      ary.append 4
      expect(ary).to eq([2, 3, 4])
    end
  end
end
