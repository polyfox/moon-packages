module Moon # :nodoc:
  module DataModel # :nodoc:
    module Model # :nodoc:
      ##
      # @param [Module] mod
      def self.included(mod)
        mod.send :include, Fields
        mod.send :include, Moon::Serializable
      end
    end
  end
end
