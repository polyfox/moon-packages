module Moon
  module DataModel
    module TypeValidators
      module Base
        private def check_object_class(key, expected, given, options = {})
          unless given.is_a?(expected)
            if options[:quiet]
              return false
            else
              msg = "[#{key}] wrong type #{given.class.inspect}" +
                    " (expected #{expected.inspect})"
              raise TypeError, msg
            end
          end
          true
        end
      end
    end
  end
end
