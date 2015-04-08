require 'std/option'

describe Moon::Option do
  context '#initialize' do
    it 'should initialize with a value' do
      my_value = 'Hello World :3'
      opt = Moon::Option.new(my_value)
      expect(opt.value).to eq(my_value)
    end
  end

  context '#map' do
    it 'should eval and replace if it has a non-blank value' do
      my_value = 'Hello World :3'
      opt = Moon::Option.new(my_value)
      opt.map { |v| v.reverse }
      expect(opt.value).to eq(my_value.reverse)
    end

    it 'should not replace, if it has a blank value' do
      opt = Moon::Option.new(nil)
      opt.map { |v| 'Egg' }
      expect(opt.value).to eq(nil)
    end
  end

  context '#blank?' do
    it 'should report blank if the value is nil' do
      opt = Moon::Option.new(nil)
      expect(opt.blank?).to eq(true)
    end

    it 'should report non-blank if the value is anything except nil' do
      opt = Moon::Option.new(false)
      expect(opt.blank?).to eq(false)
    end
  end

  context '#presence' do
    it 'should return nil if blank' do
      opt = Moon::Option.new(nil)
      expect(opt.presence).to eq(nil)
    end

    it 'should return value if non-blank' do
      opt = Moon::Option.new(false)
      expect(opt.presence).to eq(false)
    end
  end
end
