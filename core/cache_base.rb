#
# moon/core/cache_base.rb
#   General purspose cache.
#   Simply create new branches (loaders) and the cache will do the rest.
module Moon
  class CacheBase
    ##
    # @param [String] name
    def initialize(name="Cache")
      @name = name
      @cache = {}

      post_init
    end

    ##
    # Hook function called at the end of initialize
    def post_init
      #
    end

    ##
    # @overload debug { |io| do_with_io }
    # @return [Void]
    def debug
      yield STDERR
    end

    ##
    # @return [Void]
    def clear(branch_name=nil)
      if branch_name
        if cache = @cache[branch_name]
          cache.clear
        end
      else
        @cache.clear
      end
    end

    ##
    # @param [Symbol] branch_name
    def entries(branch_name)
      @cache[branch_name] || {}
    end

    ##
    # @deprecated
    def __cache_load__(branch_name, *args_org, &block)
      name, *args = *args_org
      key = [name, *args]

      debug { |l| l.puts "[#{@name}:#{branch_name}] GET #{name.inspect}, #{args.join(", ")}" }

      case loader = self.class.loader[branch_name]
      when Proc # dynamic loader
        (@cache[branch_name] ||= {})[key] ||= loader.(name, *args)
      when Hash # fixed loader
        func = loader[name]
        unless func
          raise RuntimeError,
                "[#{@name}:#{branch_name}] ERR #{name.inspect}, #{args.join(", ")} (no loader)"
        end
        (@cache[branch_name] ||= {})[key] ||= func.(*args)
      else
        raise IndexError,
              "[#{@name}:#{branch_name}] ERR #{name.inspect}, #{args.join(", ")} (no loader)"
      end
    end

    ##
    # @param [Symbol] branch_name
    # @return [Symbol]  branch_name
    # @deprecated
    def self.branch(branch_name)
      STDERR.puts "warning: CacheBase.branch is deprecated, use .cache instead"

      (@loader ||= {})[branch_name] = yield

      define_method(branch_name) do |*args_org, &block|
        __cache_load__(branch_name, *args_org, &block)
      end

      branch_name
    end

    ##
    # @param [Symbol] method_name
    def self.cache(method_name)
      alias_method "load_#{method_name}", method_name

      define_method(method_name) do |*args|
        (@cache[method_name] ||= {})[args] ||= send("load_#{method_name}", *args)
      end
    end

    class << self
      attr_reader :loader
      private :branch
      private :cache
    end
  end
end
