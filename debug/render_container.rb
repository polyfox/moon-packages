module Debug
  module RenderContainer
    def self.element_info(obj)
      "#{obj.visible ? "+" : "-"} #{obj.class.inspect}"
    end

    def self.pp_elements(obj, depth=0)
      puts Debug.format_depth(element_info(obj), depth)
      #Eventable.pretty_print(obj, depth+1)
      obj.elements.each do |element|
        pp_elements(element, depth + 1)
      end
    end

    def self.pretty_print(obj, depth=0)
      pp_elements(obj, depth)
    end
  end
end

module Moon
  class RenderContainer
    def ppd_rc(depth=0)
      Debug::RenderContainer.pretty_print(self, depth)
      self
    end
  end
end
