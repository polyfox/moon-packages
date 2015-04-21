require 'spec_helper'
require 'std/cuboid'

describe Moon::Cuboid do
  context '#initialize' do
    it 'should initialize with no args' do
      cuboid = described_class.new
    end

    it 'should initialize with args' do
      cuboid = described_class.new(2, 4, 1, 8, 16, 4)
    end
  end
end
