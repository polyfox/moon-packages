module Moon
  module DataSerializer
    class Resolver
      def resolve(data, depth)
        case data
        when Array
          data.map do |obj|
            resolve(obj, depth + 1)
          end
        when Hash
          if refname = data['&ref']
            DataLoader.file(refname)
          else
            data.each_with_object({}) do |a, r|
              k, v = *a
              r[k] = resolve(v, depth + 1)
            end
          end
        else
          data
        end
      end

      def self.resolve(data, depth = 0)
        new.resolve(data, depth)
      end
    end

    def self.load_obj_from_classname(classname, data, depth = 0)
      Object.const_get(classname).load(data, depth + 1)
    end

    def self.load_obj_hash(data, depth = 0)
      result = {}
      data.each do |key, value|
        result[key] = load_obj(value, depth + 1)
      end
      result
    end

    def self.load_obj(data, depth = 0)
      if data.is_a?(Hash)
        if data.key?('&class')
          load_obj_from_classname(data['&class'], data, depth)
        else
          load_obj_hash(data, depth)
        end
      elsif data.is_a?(Array)
        data.map do |value|
          load_obj(value)
        end
      else
        data
      end
    end

    def self.load(data, depth = 0)
      load_obj Resolver.resolve(data, depth + 1)
    end

    def self.load_file(filename, depth = 0)
      data = DataLoader.raw_file(filename)
      load DataLoader.string(data), depth + 1
    end

    class << self
      private :load_obj_from_classname
      private :load_obj_hash
      private :load_obj
    end
  end
end
