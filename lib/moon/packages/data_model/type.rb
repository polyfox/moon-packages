class Pair
  attr_accessor :key
  attr_accessor :value

  def initialize(key, value)
    @key = key
    @value = value
  end

  def [](n)
    n == 0 ? key : value
  end

  def []=(n, v)
    if n == 0
      @key = v
    else
      @value = v
    end
  end
end

class TypeCheck
  def check(obj)
    nil
  end

  def fail!
    raise TypeError
  end

  def check!(obj)
    unless check obj
      fail!
    end
  end

  def self.from(obj)
    new obj
  end
end

class ClassCheck < TypeCheck
  def initialize(klass)
    @klass = klass
  end

  def check(obj)
    obj.kind_of? @klass
  end

  def fail!
    raise TypeError, "expected object of Type #{@klass}"
  end
end

class ArrayCheck < TypeCheck
  def initialize(ary)
    @ary = ary
  end

  def check(obj)
    @ary.any? { |type| type.check(obj) }
  end

  def fail!
    raise TypeError, "expected object of any [#{@ary.join(', ')}]"
  end

  def self.from(ary)
    new(ary.map { |o| to_type(o) })
  end
end

class HashCheck < TypeCheck
  def initialize(hash)
    @hash = hash
  end

  def check(pair)
    @hash.any? do |a|
      a[0].check(pair[0]) && a[1].check(pair[1])
    end
  end

  def fail!
    raise TypeError, "expected object of #{@hash}"
  end

  def self.from(hash)
    new(hash.map { |key, value| [to_type(key), to_type(value)] }.to_h)
  end
end

def to_type(obj)
  case obj
  when Array then ArrayCheck
  when Hash  then HashCheck
  else            ClassCheck
  end.from(obj)
end

type = to_type [Numeric]
type.check! 1
type.check! 2.0
type.check! [2.0]
