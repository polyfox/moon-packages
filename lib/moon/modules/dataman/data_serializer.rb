module DataSerializer
  def self.resolve_references(data, depth = 0)
    case data
    when Array
      data.map do |obj|
        resolve_references(obj, depth + 1)
      end
    when Hash
      if refname = data['&ref']
        DataLoader.file(refname)
      else
        data.each_with_object({}) do |a, r|
          k, v = *a
          r[k] = resolve_references(v, depth + 1)
        end
      end
    else
      data
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
    load_obj(resolve_references(data, depth + 1))
  end

  def self.load_file(filename, depth = 0)
    data = DataLoader.raw_file(filename)
    load(DataLoader.string(data), depth + 1)
  end

  ##
  # @todo
  # @param [Object] obj
  # @param [Integer] depth
  def self.dump(obj, depth = 0)
    # TODO
  end

  class << self
    private :resolve_references
    private :load_obj
  end
end
