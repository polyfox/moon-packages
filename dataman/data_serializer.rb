module DataSerializer
  def self.resolve_references(data, depth=0)
    case data
    when Array
      data.map do |obj|
        resolve_references(obj, depth+1)
      end
    when Hash
      if ref = data["&ref"]
        DataLoader.file(ref)
      else
        data.each_with_object({}) do |a, r|
          k, v = *a
          r[k] = resolve_references(v, depth+1)
        end
      end
    else
      data
    end
  end

  def self.load_obj(data, depth=0)
    if data.is_a?(Hash)
      if dumpklass = data["&class"]
        Object.const_get(dumpklass).load(data)
      else
        result = {}
        data.each do |key, value|
          result[key] = load_obj(value, depth+1)
        end
        result
      end
    elsif data.is_a?(Array)
      data.map do |value|
        load_obj(value)
      end
    else
      data
    end
  end

  def self.load(data)
    load_obj(resolve_references(data))
  end

  def self.load_file(filename)
    data = DataLoader.raw_file(filename)
    load(DataLoader.string(data))
  end

  def self.dump(obj)
    # TODO
  end

  class << self
    private :resolve_references
    private :load_obj
  end
end
