require 'spec_helper'
require 'render_primitives/render_container'

describe Moon::RenderContainer do
  context '#initialize' do
    it 'initializes a render container' do
      ctx = described_class.new
    end
  end

  context '#render' do
    it 'renders the container and its children' do
      ctx = described_class.new
      ctx.render
    end
  end
end
