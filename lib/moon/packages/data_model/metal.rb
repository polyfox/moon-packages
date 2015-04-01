# :nodoc
module Moon
  ##
  # Moon::DataModel serves as the base for most structured data types in Moon
  module DataModel
    ##
    # Metal is a generic implementation of Moon::DataModel::Model
    class Metal
      include Model

      ##
      # @return [Integer] DataModel id counter
      @@dmid = 0

      # @return [Integer] Generic DataModel id
      attr_reader :dmid

      ##
      # @param [Hash<Symbol, Object>] opts
      #   Values to initialize the model with
      def initialize(opts = {})
        @dmid = @@dmid += 1

        # Some subclasses may overload the set method, so an internal
        # _dm_set_ method was created.
        _dm_set_(opts)
        initialize_fields(opts.keys)

        yield self if block_given?

        post_init
      end

      ##
      # Final initialization method
      private def post_init
        #
      end

      ##
      # @param [Array<Symbol>] dont_init
      #   A list of keys not to initialize
      private def initialize_fields(dont_init = [])
        each_field_name do |k|
          next if dont_init.any? { |s| s.to_s == k.to_s }
          init_field(k)
        end
      end

      ##
      # Set internal attributes using the hash key~value pairs.
      # These attributes are subject to validation, use #set! instead if
      # validation needs to be bypassed.
      #
      # @param [Hash<Symbol, Object>] opts
      def set(opts)
        opts.each { |k, v| self.send("#{k}=", v) }
        self
      end

      ##
      # Sets internal attributes using the Hash key~value pairs.
      # These attributes bypass validation, use #set instead if validation is
      # needed
      #
      # @param [Hash<Symbol, Object>] opts
      def set!(opts)
        opts.each { |k, v| send("_#{k}_set", v) }
        self
      end

      ##
      # Converts to a Hash
      #
      # @return [Hash<Symbol, Object>]
      def to_h
        fields_hash
      end

      ##
      # A recursive method of #to_h
      #
      # @return [Hash<Symbol, Object>]
      def to_h_r
        hsh = {}
        each_field_name do |k|
          obj = send(k)
          if obj.is_a?(Array)
            obj = obj.map do |o|
              o.respond_to?(:to_h) ? o.to_h : o
            end
          elsif obj.is_a?(Hash)
            obj = obj.each_with_object({}) do |a, hash|
              k, v = a
              hash[k] = v.respond_to?(:to_h) ? v.to_h : v
            end
          else
            obj = obj.to_h if obj.respond_to?(:to_h)
          end
          hsh[k] = obj
        end
        hsh
      end

      ##
      # Force the type conversion of each field, if a particular type
      # cannot be converted immediately, #custom_type_cast is called
      #
      # @return [self]
      def force_types
        each_field do |k, field|
          value = self[k]
          type = field.type_class
          next if value.nil? && field.allow_nil?
          next if value.is_a?(type)
          self[k] =
          if type == Array      then value.to_a
          elsif type == Float   then value.to_f
          elsif type == Hash    then value.to_h
          elsif type == Integer then value.to_i
          elsif type == String  then value.to_s
          else
            custom_type_cast(k, value)
          end
        end
        self
      end

      ##
      # @param [Symbol] key
      # @param [Object] value
      # @return [Object]
      private def custom_type_cast(key, value)
        raise "#{key}, #{value}"
      end

      alias :_dm_set_ :set
      alias :_dm_set_! :set!

      private :_dm_set_
      private :_dm_set_!
    end
  end
end
