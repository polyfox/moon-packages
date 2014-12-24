module Moon #:nodoc
  # General purspose cache.
  # Simply create new branches (loaders) and the cache will do the rest.
  class CacheBase
    # @param [String] name
    def initialize(name = nil)
      @name = name || self.class.to_s
      @cache = {}

      post_init
    end

    # Hook function called at the end of initialize
    def post_init
      #
    end

    # @overload debug { |io| do_with_io }
    # @return [Void]
    def debug
      yield STDERR
    end

    # @return [Void]
    def clear(branch_name = nil)
      if branch_name
        if cache = @cache[branch_name]
          cache.clear
        end
      else
        @cache.clear
      end
    end

    # @param [Symbol] branch_name
    def entries(branch_name)
      @cache[branch_name] || {}
    end

    # @param [Symbol] method_name
    def self.cache(method_name)
      alias_method "load_#{method_name}", method_name

      define_method(method_name) do |*args|
        (@cache[method_name] ||= {})[args] ||= send("load_#{method_name}", *args)
      end
    end

    class << self
      private :cache
    end
  end
end
