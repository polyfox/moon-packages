require 'spec_helper'
require 'std/mixins/taggable'

module Fixtures
  class TaggableObject
    include Moon::Taggable

    attr_accessor :tags

    def initialize
      @tags = []
    end
  end
end

describe Moon::Taggable do
  context '#tag' do
    it 'adds a tag' do
      obj = Fixtures::TaggableObject.new
      obj.tag('explodes')
      obj.tag('root')
      expect(obj.tags).to include('root')
      expect(obj.tags).to include('explodes')
      expect(obj).to be_tagged('root')
      expect(obj).to be_tagged('explodes')
      obj.untag('root')
      expect(obj).not_to be_tagged('root')
      expect(obj).to be_tagged('explodes')
    end

    it 'will not add duplicate tags' do
      obj = Fixtures::TaggableObject.new
      obj.tag('explodes', 'root', 'root')
      expect(obj.tags.count('root')).to eq(1)
    end
  end
end
