module Debug
  module Eventable
    def self.pretty_print(obj, depth = 0)
      last_key = nil
      obj.each_listener do |key, listener|
        if last_key != key
          puts Debug.format_depth("~ #{key}", depth)
          last_key = key
        end
        puts Debug.format_depth("` <#{listener.class} @filter=#{listener.filter} @callback=#{listener.callback}>", depth + 1)
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
