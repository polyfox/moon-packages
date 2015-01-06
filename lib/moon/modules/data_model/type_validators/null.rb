module Moon
  module DataModel
    module TypeValidators
      module Null
        include Moon::DataModel::TypeValidators::Base

        def check_type(type, key, value, options = {})
          true
        end

        extend self
      end
    end
  end
end
