module Moon #:nodoc
  # An Implementation of Tree.
  class Tree
    include Enumerable

    # @!attribute [rw] parent
    #   @return [Tree] the tree's parent
    attr_accessor :parent
    # @!attribute [rw] value
    #   @return [Object]
    attr_accessor :value

    # @param [Object] value
    def initialize(parent = nil, value = nil)
      @parent = parent
      @value = value
      @children = []
    end

    # Yields each child tree object
    #
    # @yieldparam [Tree] child
    def each(&block)
      @children.each(&block)
    end

    # Adds a Tree to the list of children
    #
    # @param [Tree] tree
    def add_tree(tree)
      @children.push(tree)
    end

    # Adds a new Tree with its value set to +value+
    #
    # @param [Object] value
    def add(value)
      add_tree Tree.new(self, value)
    end

    # Sets a child at index to the provided +tree+
    #
    # @param [Integer] index
    # @param [Tree] tree
    def set_tree(index, tree)
      @children[index] = tree
    end

    # Sets a child's value at +index+ to +value+, if the tree doesn't exist,
    # it is added and its value set.
    #
    # @param [Integer] index
    # @param [Object] value
    # @return [Tree]
    def set(index, value)
      if tree = @children[index]
        tree.tap { |t| t.value = value }
      else
        @children[index] = Tree.new(self, value)
      end
    end

    # Gets a child at +index+
    #
    # @param [Integer] index
    # @return [Tree, nil]
    def get_tree(index)
      @children[index]
    end

    # Gets a child's value at +index+.
    #
    # @param [Integer] index
    # @return [Object, nil]
    def get(index)
      (t = get_tree(index)) && t.value
    end

    # Inserts a tree into the target tree.
    #
    # @param [Integer] index
    # @param [Tree] tree
    # @return [Void]
    def insert_tree(index, tree)
      @children.insert index, tree
    end

    # Inserts a new Tree into the target tree with its value set to +value+
    #
    # @param [Integer] index
    # @param [Object] value
    # @return [Void]
    def insert(index, value)
      insert_tree index, Tree.new(self, value)
    end

    # Rejects a tree from the children.
    #
    # @yieldparam [Tree] tree
    def reject_tree(&block)
      @children.reject!(&block)
    end

    # Deletes a child tree and returns it
    #
    # @param [Tree] tree
    # @return [Tree]
    def delete_tree(tree)
      @children.delete(tree)
    end

    # Deletes a child tree by checking its value.
    #
    # @param [Object] value
    # @return [Void]
    def delete(value)
      reject_tree { |tree| tree.value == value }
    end

    # Removes a tree from the children given an +index+
    #
    # @param [Integer] index
    # @return [Tree] the tree removed
    def remove_tree(index)
      @children.delete_at(index)
    end

    # The size of the tree, excluding the size of its children.
    #
    # @return [Integer] size
    def size
      @children.size
    end

    # The total size of the tree, including its children's total_size
    #
    # @return [Integer] size
    def total_size
      size + @children.inject(0) { |r, tree| r + tree.total_size }
    end

    # Looks in the tree and its children for anything that evaluates the block
    # to true.
    #
    # @yieldparam [Tree] tree
    # @return [Tree, nil]
    def find_tree(&block)
      return to_enum(:find_tree) unless block_given?
      return self if yield self
      each do |tree|
        return tree if yield tree
        tree.find_tree(&block)
      end
      nil
    end

    # Same as find_tree, will return the value of the found tree or nil.
    #
    # @yieldparam [Tree] tree
    # @return [Object, nil]
    def find(&block)
      (obj = find_tree(&block)) ? obj.value : nil
    end
  end
end
