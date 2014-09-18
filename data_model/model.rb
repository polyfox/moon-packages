module Moon
  module DataModel
    module Model
      def self.included(mod)
        mod.include Fields
        mod.include ESON
      end
    end
  end
end
