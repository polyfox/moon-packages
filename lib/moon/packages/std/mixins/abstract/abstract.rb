require 'std/err/abstract_method_error'

module Moon
  module Abstract
    # Creates a new abstract method.
    # A abstract method will fail with a AbstractMethodError when called.
    # It is intended to be rewritten in the subclass before usage.
    #
    # @param [Symbol] method_name
    def abstract(method_name)
      define_method method_name do |*|
        fail AbstractMethodError.new(method_name)
      end
    end

    # Creates a abstract method, similar to attr_writer
    #
    # @param [Symbol] method_name
    def abstract_attr_writer(method_name)
      abstract "#{method_name}="
    end

    # Creates a abstract method, similar to attr_reader
    #
    # @param [Symbol] method_name
    def abstract_attr_reader(method_name)
      abstract method_name
    end

    # Creates a abstract method, similar to attr_accessor
    #
    # @param [Symbol] method_name
    def abstract_attr_accessor(method_name)
      abstract_attr_writer(method_name)
      abstract_attr_reader(method_name)
      method_name
    end
  end
end
