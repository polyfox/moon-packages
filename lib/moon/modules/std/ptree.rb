class Pair
  attr_accessor :key
  attr_accessor :value

  def initialize(key, value)
    @key, @value = key, value
  end
end

class Object
  def to_tree(mark = {})
    return mark[self] += 1 if mark.key?(self)
    mark[self] ||= 0
    mark[self] += 1
    tree = Moon::Tree.new
    instance_variables.each do |name|
      v = instance_variable_get(name)
      tree.add Pair.new(name, v.to_tree(mark))
    end
    tree
  end
end

def ptree(obj)
  p obj.to_tree
end


cuboid = Moon::Cuboid.new(1, 2, 3, 4, 5, 6)

ptree cuboid
