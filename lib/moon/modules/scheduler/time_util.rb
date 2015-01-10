module Moon #:nodoc:
  # TimeUtil (Time Utility), has nothing to do with ruby Time, this module
  # has various methods for dealing with durations, timings etc.. for Moon.
  module TimeUtil
    ##
    # @return [Hash<String, Float>]
    # @api
    DURATION_SUFFIX = {
      ''  => 0.001,
      's' => 1.0,
      'm' => 60.0,
      'h' => 3_600.0,
      'd' => 86_400.0,
      'w' => 604_800.0,
      'M' => 2_592_000.0,
      'y' => 31_536_000.0
    }

    ##
    # @param [String] str
    # @return [Float] duration  in seconds
    def self.parse_duration(str)
      #   - milliseconds
      # s - seconds
      # m - minutes
      # h - hours
      # d - days
      # w - weeks
      # M - months
      # y - years
      # Now lets be honest here, who would be running this thing for more than
      # a few hours anyway...
      value = 0.0
      str.scan(/(\d+|\d+\.\d+)([smhdwMy])?/).each do |a|
        v = a[0].to_f
        suffix = a[1].to_s
        value = v * DURATION_SUFFIX[suffix]
      end
      value
    end

    # Converts a given object to a duration, if the object is a string
    # it goes though the parse_duration method instead.
    #
    # @param [String, #to_f] str
    # @return [Numeric]
    def self.to_duration(obj)
      obj.is_a?(String) ? parse_duration(obj) : obj.to_f
    end
  end
end
