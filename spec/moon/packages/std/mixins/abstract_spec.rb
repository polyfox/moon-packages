require 'std/mixins/abstract'

module Fixtures
  class MyAbstractClass
    abstract_attr_accessor :overwrite_me_later
  end
end

describe Moon::Abstract do
  context 'abstract properties' do
    it 'should raise an AbstractMethodError if an abstract method is called' do
      obj = Fixtures::MyAbstractClass.new
      expect { obj.overwrite_me_later }.to raise_error(AbstractMethodError)
      expect { obj.overwrite_me_later = 1 }.to raise_error(AbstractMethodError)
    end
  end
end
