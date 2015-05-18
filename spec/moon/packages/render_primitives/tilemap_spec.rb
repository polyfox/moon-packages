require 'spec_helper'
require 'render_primitives/tilemap'

describe Moon::Tilemap do
  context '#initialize' do
    it 'initializes a tilemap' do
      ctx = described_class.new
    end
  end
end
