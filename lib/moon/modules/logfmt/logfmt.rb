# Implementation of logfmt for Moon
module Logfmt
  # Regular expression used for checking strings that may need escaping.
  # This regular expression will validate true if the string doesn't need
  # escaping.
  UNESCAPED_STRING = /\A[a-zA-Z0-9\.\-\_\,\:\;\/]*\z/i

  # Formats provided data in a logfmt format.
  #
  # @param [Hash<[String, Symbol], String>] data
  # @return [String]
  def self.format_context(data)
    data.map do |pair|
      key, value = *pair
      case value
      when Array
        value = value.join(',')
      else
        value = value.to_s
      end
      value = value.dump unless value =~ UNESCAPED_STRING
      "#{key}=#{value}"
    end.join(' ')
  end

  # Basic Logger class for Logfmt writing
  # The main functions are #write and #new
  # #new will copy the current logger and append its context data
  class Logger
    # The underlaying IO to write to, the default is STDOUT
    # @return [IO]
    attr_accessor :io
    # Whether to prepend timestamps to the logs
    # @return [Boolean]
    attr_accessor :timestamp
    # Context related data, this protected, don't even think of using it.
    # @return [Hash<[String, Symbol], String>]
    attr_accessor :context
    protected :context
    protected :context=

    # @param [Hash<[String, Symbol], String>] data
    def initialize(data = {})
      @io = STDOUT
      @context = data
      @timestamp = true
    end

    # @param [Logfmt::Logger] org
    # @return [self]
    def initialize_copy(org)
      @context = org.context.dup
      self
    end

    # Formats the provided context data
    #
    # @param [Hash<[String, Symbol], String>] data
    # @return [String]
    private def format_context(data)
      Logfmt.format_context data
    end

    # Most basic function for the logger, writes a new log line.
    #
    # @param [Hash<[String, Symbol], String>] data
    def write(data)
      pre = {}
      if @timestamp
        t = Time.now
        fmt = '%04d-%02d-%02dT%02d:%02d:%02d%s'
        s = sprintf(fmt, t.year, t.mon, t.day, t.hour, t.min, t.sec, t.zone)
        pre[:now] = s
      end
      @io.puts format_context(pre.merge(context.merge(data)))
    end

    # Creates a new context by forking the current logger
    #
    # @param [Hash<[Symbol, String], String>] data
    def new(data)
      logger = dup
      logger.context.merge!(data)
      logger
    end
  end
end
