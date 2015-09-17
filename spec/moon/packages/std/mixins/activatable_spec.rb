require 'spec_helper'
require 'std/mixins/activatable'

module Fixtures
  class ActivatableObject
    include Moon::Activatable

    attr_accessor :active

    def initialize
      deactivate
    end
  end
end

describe Moon::Activatable do
  context 'Active state' do
    it 'should report if an object is active' do
      obj = Fixtures::ActivatableObject.new
      obj.deactivate

      expect(obj).to be_inactive
      expect(obj).not_to be_active

      obj.activate

      expect(obj).to be_active
      expect(obj).not_to be_inactive
    end
  end
end
