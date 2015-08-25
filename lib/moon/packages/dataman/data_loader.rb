module Moon
  # DataLoader is a helper module for loading data from the filesystem.
  # DataLoader assumes that all data is serialized as YAML with the file
  # extension .yml.
  module DataLoader
    # Rootpath of the data, defauled to "data"
    # @return [String]
    def self.rootpath
      "data"
    end

    # Loads data from a String
    #
    # @return [String]
    def self.string(string)
      YAML.load(string)
    end

    # Loads data from a file as is.
    #
    # @param [String] filename
    # @return [String]
    def self.raw_file(filename)
      File.read("#{rootpath}/#{filename}.yml")
    end

    # Loads data from a file and loads it using YAML
    #
    # @param [String] filename
    def self.file(filename)
      STDERR.print "[#{self}] loading file(#{filename})"
      data = string raw_file(filename)
      STDERR.puts " LOADED"
      data
    end
  end
end
