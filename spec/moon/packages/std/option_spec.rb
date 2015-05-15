require 'spec_helper'
require 'std/option'

describe Moon::Option do
  context '#initialize' do
    it 'should initialize with a value' do
      my_value = 'Hello World :3'
      opt = described_class.new(my_value)
      expect(opt.value).to eq(my_value)
    end
  end

  context '#map' do
    it 'evals and replaces if it has a non-blank value' do
      my_value = 'Hello World :3'
      opt = described_class.new(my_value)
      opt.map { |v| v.reverse }
      expect(opt.value).to eq(my_value.reverse)
    end

    it 'does not replace if it has a blank value' do
      opt = described_class.new(nil)
      opt.map { |v| 'Egg' }
      expect(opt.value).to be_nil
    end

    it 'can accept a method_name instead of block' do
      opt = described_class.new('I Am A Cow')
      opt.map(:size)
      expect(opt.value).to eq(10)
    end
  end

  context '#blank?' do
    it 'should report blank if the value is nil' do
      opt = described_class.new(nil)
      expect(opt).to be_blank
    end

    it 'should report non-blank if the value is anything except nil' do
      opt = described_class.new(false)
      expect(opt.blank?).to eq(false)
    end
  end

  context '#presence' do
    it 'should return nil if blank' do
      opt = described_class.new(nil)
      expect(opt.presence).to be_nil
    end

    it 'should return value if non-blank' do
      opt = described_class.new(false)
      expect(opt.presence).to eq(false)
    end
  end
end
