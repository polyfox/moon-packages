module YAML #:nodoc:
  # Loads a file +filename+ and parses it as YAML
  #
  # @param [String] filename
  # @return [Object] loaded data
  def self.load_file(filename)
    load File.read(filename)
  end

  # Saves a file after dumping it as YAML.
  #
  # @param [String] filename  file to write to.
  # @param [Object] obj  to dump
  def self.save_file(filename, obj)
    File.open(filename, "w") { |f| f.write dump(obj) }
  end
end
