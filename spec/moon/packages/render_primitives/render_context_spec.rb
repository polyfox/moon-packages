require 'spec_helper'
require 'render_primitives/render_context'

describe Moon::RenderContext do
  context '#initialize' do
    it 'initializes a render context' do
      ctx = described_class.new
    end
  end
end
