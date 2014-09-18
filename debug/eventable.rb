module Debug
  module Eventable
    def self.pretty_print(obj, depth=0)
      evl = obj.instance_variable_get("@event_listeners")
      evl.each do |key, ary|
        puts Debug.format_depth("~ #{key}", depth)
        ary.each do |value|
          puts Debug.format_depth("` #{value.class.inspect}|#{value.callback}", depth+1)
        end
      end
    end
  end
end

module Moon
  module Eventable
    def ppd_ev(depth=0)
      Debug::Eventable.pretty_print(self, depth)
      self
    end
  end
end
