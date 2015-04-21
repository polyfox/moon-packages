module Moon
  module Prototype
    # @param [String, Symbol] singular_name
    # @return [Symbol]
    # @api
    def self.plural_sym(singular_name)
      singular_name.to_s.pluralize.to_sym
    end

    def self.varname_sym(singular_name)
      "@__prototype_#{plural_sym(singular_name)}__".to_sym
    end

    def self.collective_sym(singular_name)
      #"my_#{plural_sym(singular_name)}".to_sym
      # originally I planned to name each instance level attr as my_<name>,
      # but it seems unusual on the userside of things.
      "#{plural_sym(singular_name)}".to_sym
    end

    def self.enum_sym(singular_name)
      "each_#{singular_name}".to_sym
    end

    def self.all_sym(singular_name)
      "all_#{plural_sym(singular_name)}"
    end

    # @return [Symbol]
    # @api
    private def define_prototype_enum(singular_name, options = {})
      my_name = Prototype.collective_sym singular_name
      enum_name = Prototype.enum_sym singular_name

      define_method enum_name do |&block|
        # if the block given is invalid, return an Enumerator instead
        return to_enum enum_name unless block
        # call each instance prototype_attr
        prototype_call my_name do |objs|
          objs.each do |*a|
            block.call(*a)
          end
        end
      end
    end

    # @return [Symbol]
    # @api
    private def define_prototype_instance_collection(singular_name, options = {})
      plural_name = Prototype.plural_sym singular_name
      variable_name = Prototype.varname_sym singular_name
      my_name = Prototype.collective_sym singular_name

      # create default function
      dfault = if options.key?(:default)
        # obtain the default value
        v = options[:default]
        # default must always be a Proc
        v.is_a?(Proc) ? v : (proc { v })
      else
        # by default, all new prototype_attrs are Arrays
        proc { [] }
      end

      define_method my_name do
        var = instance_variable_get variable_name
        if var.nil?
          var = dfault.call
          instance_variable_set variable_name, var
        end
        var
      end
    end

    # Calls `method` on each ancestor and yields the result of the method.
    # The ancestor is skipped if it does not respond_to? +method+
    #
    # @param [String, Symbol] method
    # @yieldparam [Object] result from call
    def prototype_call(method)
      return to_enum :prototype_call, method unless block_given?

      ancestors.reverse_each do |klass|
        yield klass.send(method) if klass.respond_to?(method)
      end
    end

    # Prototype attributes are Arrays of values which belong to a set of classes.
    # They are not class variables which are shared by the entire ancestor line.
    #
    # @param [String, Symbol] singular_name
    # @return [Void]
    private def prototype_attr(singular_name, options = {})
      pn = define_prototype_instance_collection singular_name, options
      enum_name = define_prototype_enum singular_name, options
      # all prototype attributes
      all_name = Prototype.all_sym singular_name
      define_method all_name do
        send(enum_name).to_a
      end
    end
  end
end
