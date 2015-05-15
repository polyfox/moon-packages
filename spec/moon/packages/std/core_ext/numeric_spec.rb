require 'spec_helper'
require 'std/core_ext/numeric'

describe Numeric do
  context '#lerp' do
    it 'lerps from self to target' do
      expect(1.lerp(2, 0.5)).to eq(1.5)
    end
  end

  context '#to_degrees' do
    it 'converts self (as a radian) to degrees' do
      expect(1.2.to_degrees).to eq(69)
    end
  end

  context '#to_radians' do
    it 'converts self (as a degree) to radians' do
      expect(120.to_radians.round(1)).to eq(2.1)
    end
  end

  context '#max' do
    it 'caps self at max' do
      expect(1.max(0)).to eq(1)
      expect(2.max(3)).to eq(3)
    end
  end

  context '#min' do
    it 'caps self at min' do
      expect(1.min(0)).to eq(0)
      expect(2.min(3)).to eq(2)
    end
  end

  context '#clamp' do
    it 'clamps values in range' do
      expect(12.clamp(0, 8)).to eq(8)
      expect(1.clamp(2, 8)).to eq(2)
      expect(3.clamp(2, 8)).to eq(3)
    end
  end

  # vector methods
  context '#to_vec1' do
    it 'converts self to a Vector1' do
      v = 1.to_vec1
      expect(v).to be_instance_of(Moon::Vector1)
    end
  end

  context '#to_vec2' do
    it 'converts self to a Vector2' do
      v = 1.to_vec2
      expect(v).to be_instance_of(Moon::Vector2)
    end
  end

  context '#to_vec3' do
    it 'converts self to a Vector3' do
      v = 1.to_vec3
      expect(v).to be_instance_of(Moon::Vector3)
    end
  end

  context '#to_vec4' do
    it 'converts self to a Vector1' do
      v = 1.to_vec4
      expect(v).to be_instance_of(Moon::Vector4)
    end
  end
end
