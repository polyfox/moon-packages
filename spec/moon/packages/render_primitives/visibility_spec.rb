require 'spec_helper'
require 'render_primitives/visibility'

module Fixtures
  class VisibilityObject
    include Moon::RenderPrimitive::Visibility

    attr_accessor :visible
  end
end

describe Moon::RenderPrimitive::Visibility do
  it 'controls the object is visibility' do
    obj = Fixtures::VisibilityObject.new
    expect(obj).to be_invisible
    obj.show
    expect(obj).to be_visible
    obj.hide
    expect(obj).to be_invisible
  end
end
