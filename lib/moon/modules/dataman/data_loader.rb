##
# DataLoader assumes that all data will be serialized as YAML
module DataLoader
  def self.string(string)
    YAML.load(string)
  end

  def self.raw_file(filename)
    File.read("data/#{filename}.yml")
  end

  def self.file(filename)
    STDERR.puts "[#{self}] .file(#{filename})"
    string(raw_file(filename))
  end
end
