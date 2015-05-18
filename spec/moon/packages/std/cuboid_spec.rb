require 'spec_helper'
require 'std/cuboid'

describe Moon::Cuboid do
  context '#initialize' do
    it 'initializes with no args' do
      cuboid = described_class.new
      expect(cuboid.x).to eq(0)
      expect(cuboid.y).to eq(0)
      expect(cuboid.z).to eq(0)
      expect(cuboid.w).to eq(0)
      expect(cuboid.h).to eq(0)
      expect(cuboid.d).to eq(0)
    end

    it 'initializes with a number' do
      cuboid = described_class.new(4)
      expect(cuboid.x).to eq(0)
      expect(cuboid.y).to eq(0)
      expect(cuboid.z).to eq(0)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(4)
      expect(cuboid.d).to eq(4)
    end

    it 'initializes with a vector3' do
      cuboid = described_class.new(Moon::Vector3.new(4, 8, 16))
      expect(cuboid.x).to eq(0)
      expect(cuboid.y).to eq(0)
      expect(cuboid.z).to eq(0)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(8)
      expect(cuboid.d).to eq(16)
    end

    it 'initializes with a hash (:position, :size)' do
      cuboid = described_class.new(position: Moon::Vector3.new(1, 2, 3), size: Moon::Vector3.new(4, 5, 6))
      expect(cuboid.x).to eq(1)
      expect(cuboid.y).to eq(2)
      expect(cuboid.z).to eq(3)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(5)
      expect(cuboid.d).to eq(6)
    end

    it 'initializes with a hash (:x, :y, :z, :w, :h, :d)' do
      cuboid = described_class.new(x: 1, y: 2, z: 3, w: 4, h: 5, d: 6)
      expect(cuboid.x).to eq(1)
      expect(cuboid.y).to eq(2)
      expect(cuboid.z).to eq(3)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(5)
      expect(cuboid.d).to eq(6)
    end

    it 'initializes with a Cuboid' do
      src = described_class.new(1, 2, 3, 4, 5, 6)
      cuboid = described_class.new(src)
      expect(cuboid).to eq(src)
    end

    it 'initializes with 2 args' do
      cuboid = described_class.new(2, 4)
      expect(cuboid.x).to eq(2)
      expect(cuboid.y).to eq(2)
      expect(cuboid.z).to eq(2)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(4)
      expect(cuboid.d).to eq(4)
    end

    it 'initializes with 6 args' do
      cuboid = described_class.new(2, 4, 1, 8, 16, 7)
      expect(cuboid.x).to eq(2)
      expect(cuboid.y).to eq(4)
      expect(cuboid.z).to eq(1)
      expect(cuboid.w).to eq(8)
      expect(cuboid.h).to eq(16)
      expect(cuboid.d).to eq(7)
    end

    it 'fails if given odd arguments' do
      expect { described_class.new(1, 2, 3) }.to raise_error ArgumentError
    end

    it 'fails if given an inavlid object' do
      expect { described_class.new(nil) }.to raise_error TypeError
    end
  end

  context '#==' do
    it 'compares with a Cuboid' do
      cuboid = Moon::Cuboid.new(1, 2, 3, 4, 5, 6)
      other = Moon::Cuboid.new(1, 2, 3, 4, 5, 6)
      expect(cuboid).to eq(other)
    end

    it 'cant compare other objects' do
      cuboid = Moon::Cuboid.new(1, 2, 3, 4, 5, 6)
      expect(cuboid).not_to eq(nil)
      expect(cuboid).not_to eq([1, 2, 3, 4, 5, 6])
    end
  end

  context '#x2' do
    it 'returns the right' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid.x2).to eq(5)
    end
  end

  context '#y2' do
    it 'returns the bottom' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid.y2).to eq(7)
    end
  end

  context '#z2' do
    it 'returns the z + depth' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid.z2).to eq(9)
    end
  end

  context '#to_h' do
    it 'returns a Hash with all properties' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid.to_h).to eq(x: 1, y: 2, z: 3, w: 4, h: 5, d: 6)
    end
  end

  context '#to_rect_xy' do
    it 'returns a Rect representing the xy plane' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      actual = cuboid.to_rect_xy
      expect(actual.to_a).to eq([1, 2, 4, 5])
    end
  end

  context '#to_rect_xz' do
    it 'returns a Rect representing the xz plane' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      actual = cuboid.to_rect_xz
      expect(actual.to_a).to eq([1, 3, 4, 6])
    end
  end

  context '#to_rect_yz' do
    it 'returns a Rect representing the yz plane' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      actual = cuboid.to_rect_yz
      expect(actual.to_a).to eq([2, 3, 5, 6])
    end
  end

  context '#position' do
    it 'returns the cuboid\'s position' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid.position.to_a).to eq([1, 2, 3])
      cuboid.position = [8, 9, 10]
      expect(cuboid.x).to eq(8)
      expect(cuboid.y).to eq(9)
      expect(cuboid.z).to eq(10)
    end
  end

  context '#resize' do
    it 'resizes the cuboid' do
      cuboid = described_class.new(1, 2, 3, 1, 2, 3)
      expect(cuboid.x).to eq(1)
      expect(cuboid.y).to eq(2)
      expect(cuboid.z).to eq(3)
      expect(cuboid.w).to eq(1)
      expect(cuboid.h).to eq(2)
      expect(cuboid.d).to eq(3)
      cuboid.resize(4, 5, 6)
      expect(cuboid.x).to eq(1)
      expect(cuboid.y).to eq(2)
      expect(cuboid.z).to eq(3)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(5)
      expect(cuboid.d).to eq(6)
    end
  end

  context '#empty?' do
    it 'checks if the cuboid is empty?' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid).not_to be_empty

      cuboid2 = described_class.new(1, 2, 3, 0, 0, 0)
      expect(cuboid2).to be_empty
    end
  end

  context '#contains?' do
    it 'checks if the cuboid\'s volume contains the given point' do
      cuboid = described_class.new(1, 2, 3, 4, 5, 6)
      expect(cuboid.contains?(1, 2, 3)).to eq(true)
      expect(cuboid.contains?(1, 6, 3)).to eq(true)
      expect(cuboid.contains?(Moon::Vector3.new(2, 5, 5))).to eq(true)
      expect(cuboid.contains?(Moon::Vector3.new(2, 5, 10))).to eq(false)
    end
  end

  context '.[]' do
    it 'converts the given object to a cuboid' do
      cuboid = described_class[4]
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(4)
      expect(cuboid.d).to eq(4)
    end

    it 'converts the given objects to a cuboid' do
      cuboid = described_class[Moon::Vector3.new(1, 2, 3), 4]
      expect(cuboid.x).to eq(1)
      expect(cuboid.y).to eq(2)
      expect(cuboid.z).to eq(3)
      expect(cuboid.w).to eq(4)
      expect(cuboid.h).to eq(4)
      expect(cuboid.d).to eq(4)
    end
  end
end
