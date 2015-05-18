require 'spec_helper'
require 'render_primitives/tilemap'
require 'data_bags/data_matrix'

describe Moon::Tilemap do
  context '#initialize' do
    it 'initializes a tilemap' do
      ctx = described_class.new
    end
  end

  context '#render' do
    it 'renders the tilemap' do
      ctx = described_class.new
      ctx.render

      ctx.data = Moon::DataMatrix.new 4, 4, 4
      ctx.render

      ctx.tileset = Moon::Spritesheet.new fixture_pathname('fixtures/resources/a004x004.png'), 4, 4
      ctx.render
    end
  end
end
