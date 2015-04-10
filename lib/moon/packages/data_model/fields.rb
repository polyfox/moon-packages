require 'std/mixins/serializable'
require 'std/mixins/prototype'
require 'data_model/field'

module Moon
  module DataModel
    class FieldError < RuntimeError
    end

    class FieldNotFound < FieldError
    end

    module Fields
      # Patches the provided options hash.
      #
      # @param [Hash] options
      # @return [Hash] same one given
      def self.adjust_field_options(klass, options)
        # set the class default settings
        klass.each_field_setting do |key, value|
          options[key] = value
        end

        # if the default value is set to nil, and allow_nil hasn't already
        # been set, then the field is allowed to be nil.
        if options.key?(:default) && options[:default].nil?
          options[:allow_nil] = true unless options.key?(:allow_nil)
        end

        # if default value was not set, but the field allows nil,
        # then the default value is nil
        if !options.key?(:default) && options[:allow_nil]
          options[:default] = nil
        end

        # if no type was given, assume it allows anything, therefore Object
        unless options.key?(:type)
          options[:type] = Object
        end

        options
      end

      module ClassMethods
        include Serializable::Properties::ClassMethods

        prototype_attr :field, default: proc { {} }
        prototype_attr :field_setting, default: proc { {} }

        def find_field(expected_key)
          each_field do |key, value|
            return value if expected_key == key
          end
          nil
        end

        #
        def fetch_field(expected_key)
          find_field(expected_key) ||
            (raise FieldNotFound, "could not find field #{key}.")
        end

        # Define a new field with option adjustments
        #
        # @param [Symbol] name
        # @param [Hash] options
        # @return [Symbol]
        def field(name, options = {})
          add_field name, Fields.adjust_field_options(self, options)
        end

        # @overload field_setting(key)
        #   Retrives value at key
        #   @param [Symbol] key
        #   @return [Object] value at key
        #
        # @overload field_setting(key, value)
        #   Sets value at key
        #   @param [Symbol] key
        #   @param [Object] value
        #   @return [Void]
        #
        # @overload field_setting(options)
        #   Merges the options into the field settings
        #   @param [Hash] options
        #   @return [Void]
        def field_setting(obj, *args)
          # allows you to temporarily apply the field_settings to the block.
          if block_given?
            org = field_settings.dup
            field_setting(obj, *args)
            yield self
            field_setting org
          else
            if Hash === obj
              field_settings.merge!(obj)
            else
              if args.size > 0
                field_settings[obj] = args.singularize
              else
                field_settings[obj]
              end
            end
          end
        end

        private def define_field_writer(field, name)
          setter = "_#{name}_set"
          alias_method setter, "#{name}="
          define_method "#{name}=" do |obj|
            field.check_type(name, obj) if validate_fields?
            send setter, obj
          end
        end

        # Define a new field, without option adjustments
        #
        # @param [Symbol] name
        # @param [Hash] options
        private def add_field(name, options)
          field = fields[name.to_sym] = Field.new(options)

          # first setup the Serializable property, this also creates the
          # initial attr for us
          property_accessor name
          # next we'll need to overwrite the writer created by property_accessor,
          # with our field validation one.
          define_field_writer field, name

          name.to_sym
        end

        # @param [Symbol] sym
        def remove_field(sym)
          fields.delete(sym.to_sym)
        end

        # Defines a new Array field, is a shorthand for field type: [Type]
        #
        # @return [Symbol]
        def array(sym, options)
          size = options.delete(:size) || 0
          default = (options[:default] || proc{Array.new(size)})
          field sym, options.merge(type: [options.fetch(:type)],
                                   default: default)
        end

        # Defines a new Hash field, is a shorthand for field type: {Type=>Type}
        #
        # @return [Symbol]
        def dict(sym, options)
          default = (options[:default] || proc{Hash.new})
          field sym, options.merge(type: {options.fetch(:key)=>options.fetch(:value)},
                                   default: default)
        end
      end

      module InstanceMethods
        include Serializable::Properties::InstanceMethods
        # this allows Fields to behave like Hashes :)
        include Enumerable

        # @param [Symbol] key
        # @param [Object] value
        # @return [Void]
        # TODO properly handle field setters
        def field_set(key, value)
          send "#{key}=", value
        end

        # @param [Symbol] key
        # @return [Object]
        # TODO properly handle field getters
        def field_get(key)
          send key
        end

        # @return [Array[Symbol, Object]]
        def assoc(key)
          [key, field_get(key)]
        end

        ##
        # @param [Symbol] key
        private def init_field(key)
          field = self.class.fetch_field(key)
          field_set key, field.make_default(self)
        end

        ##
        # Initializes all available fields for the model
        private def init_fields
          each_field_name do |key|
            init_field(key)
          end
        end

        ##
        # @example
        #   each_field do |key, field|
        #   end
        def each_field(&block)
          return to_enum :each_field unless block_given?
          self.class.each_field.each(&block)
        end

        # @example
        #   each_field_name do |key|
        #   end
        def each_field_name
          return to_enum :each_field_name unless block_given?
          each_field do |k, _|
            yield k
          end
        end
        alias :each_key :each_field_name

        # @example
        #   each_field_with_value do |key, field, value|
        #   end
        def each_field_with_value
          return to_enum :each_field_with_value unless block_given?
          each_field do |k, field|
            yield k, field, field_get(k)
          end
        end

        ##
        # @example
        #   each do |key, value|
        #   end
        def each
          return to_enum :each unless block_given?
          each_field_with_value do |key, _, value|
            yield key, value
          end
        end

        # @return [Boolean]
        def validate_fields?
          true
        end

        # @return [Hash<Symbol, Object>]
        def fields_hash
          each_field_name.map { |k, h| assoc(k) }.to_h
        end

        # Runs the validation for each field on the model.
        #
        # @return [self]
        def validate
          each_field do |key, field|
            field.check_type(key, field_get(key))
          end
          self
        end
      end

      def self.included(mod)
        mod.extend         ClassMethods
        mod.send :include, InstanceMethods
      end
    end
  end
end
