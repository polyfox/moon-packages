module Debug
  module Eventable
    def self.pretty_print(obj, depth = 0)
      last_key = nil
      obj.each_listener do |key, cb|
        if last_key != key
          puts Debug.format_depth("~ #{key}", depth)
          last_key = key
        end
        puts Debug.format_depth("` #{cb}", depth + 1)
      end
    end
  end
end

module Moon
  module Eventable
    def ppd_ev(depth = 0)
      Debug::Eventable.pretty_print(self, depth)
      self
    end
  end
end
