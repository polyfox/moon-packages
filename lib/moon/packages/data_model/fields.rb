module Moon
  module DataModel
    module Fields
      module ClassMethods
        include Serializable::Properties::ClassMethods

        ##
        # Returns all fields pretaining to this class only
        #
        # @return [Hash<Symbol, Field>]
        def fields
          (@fields ||= {})
        end

        ##
        # Traverses all parent classes and returns every field every defined
        # in the object chain
        #
        # @return [Array<Symbol>]
        def all_fields
          ancestors.reverse.each_with_object({}) do |klass, hash|
            hash.merge!(klass.fields) if klass.respond_to?(:fields)
          end
        end

        ##
        # Define a new field with option adjustments
        #
        # @param [Symbol] name
        # @param [Hash] options
        # @return [Symbol]
        def field(name, options)
          # if the default value is set to nil, and allow_nil hasn't already
          # been set, then assign it as true
          if options.key?(:default) && options[:default].nil?
            options[:allow_nil] = true unless options.key?(:allow_nil)
          end
          # if default value does not exist, but the field allows nil
          # set the default as nil
          if !options.key?(:default) && options[:allow_nil]
            options[:default] = nil
          end

          add_field name, options
        end

        ##
        # Define a new field, without option adjustments
        #
        # @param [Symbol] name
        # @param [Hash] options
        private def add_field(name, options)
          field = fields[name.to_sym] = Field.new(options)

          setter = "_#{name}_set"

          property_accessor name
          alias_method setter, "#{name}="

          define_method "#{name}=" do |obj|
            field.check_type(name, obj) if validate_fields?
            send setter, obj
          end

          name.to_sym
        end

        ##
        # @param [Symbol] sym
        def remove_field(sym)
          fields.delete(sym.to_sym)
        end

        ##
        # Defines a new Array field, is a shorthand for field type: [Type]
        #
        # @return [Symbol]
        def array(sym, options)
          size = options.delete(:size) || 0
          default = (options[:default] || proc{Array.new(size)})
          field sym, options.merge(type: [options.fetch(:type)],
                                   default: default)
        end

        ##
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

        # this allows Models to behave like Hashes :)
        include Enumerable

        # @return [Array[Symbol, Object]]
        def assoc(key)
          [key, send(key)]
        end

        ##
        # @param [Symbol] key
        private def init_field(key)
          field = self.class.all_fields.fetch(key)
          send "#{key}=", field.make_default(self)
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
        #   each do |key, value|
        #   end
        def each
          return enum_for(:each) unless block_given?
          each_field_with_value do |key, _, value|
            yield key, value
          end
        end

        ##
        # @example
        #   each_field do |key, field|
        #   end
        def each_field(&block)
          return enum_for(:each_field) unless block_given?
          self.class.all_fields.each(&block)
        end

        # @example
        #   each_field_name do |key|
        #   end
        def each_field_name
          return enum_for(:each_field_name) unless block_given?
          each_field do |k, _|
            yield k
          end
        end
        alias :each_key :each_field_name

        # @example
        #   each_field_with_value do |key, field, value|
        #   end
        def each_field_with_value
          return enum_for(:each_field_with_value) unless block_given?
          each_field do |k, field|
            yield k, field, send(k)
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

        # @return [self]
        def validate
          each_field do |key, field|
            field.check_type(key, send(key))
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
