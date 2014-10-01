##
# DataModel serves as the base class for all other Data objects in ES
# This was copied from the original Earthen source and updated to with moon.
module Moon
  module DataModel
    class Metal
      include Model

      @@dmid = 0

      attr_reader :dmid          # DataModel ID

      ##
      # @param [Hash<Symbol, Object>] opts
      #   Values to initialize the model with
      def initialize(opts={})
        @dmid = @@dmid += 1

        # Some subclasses may overload the set method, so an internal
        # _dm_set_ method was created.
        _dm_set_(opts)
        initialize_fields(opts.keys)

        yield self if block_given?

        post_init
      end

      def post_init
        #
      end

      ##
      # @param [Array<Symbol>] dont_init
      #   A list of keys not to initialize
      def initialize_fields(dont_init=[])
        each_field_name do |k|
          next if dont_init.include?(k)
          init_field(k)
        end
      end

      ##
      # @param [Hash<Symbol, Object>] opts
      # Set internal attributes using the hash key~value pairs.
      # These attributes are subject to validation, use #set! instead if
      # validation needs to be bypassed.
      def set(opts)
        opts.each { |k, v| self.send("#{k}=", v) }
        self
      end

      ##
      # @param [Hash<Symbol, Object>] opts
      # Sets internal attributes using the Hash key~value pairs.
      # These attributes bypass validation, use #set instead if validation is
      # needed
      def set!(opts)
        opts.each { |k, v| send("_#{k}_set", v) }
        self
      end

      ##
      # A recursive version of to_h
      # @return [Hash<Symbol, Object>]
      def to_h
        fields_hash
      end

      ##
      # A recursive version of to_h
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
      def custom_type_cast(key, value)
        raise "#{key}, #{value}"
      end

      alias :_dm_set_ :set
      alias :_dm_set_! :set!

      private :_dm_set_
      private :_dm_set_!

      private :custom_type_cast
      private :initialize_fields
      private :post_init
    end
  end
end
