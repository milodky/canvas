require 'canvas/pigment'
require 'yaml'
module Canvas
  module Pigment
    def initialize!(path)
      definition = (path.is_a?(Hash) ? path : YAML.load_file(path)).with_indifferent_access
      # a class may not have any nested classes
      definition['nested_classes'] ||= {}
      definition['configuration']  ||= {}
      _base = self
      #############################################################
      # define a new class
      #
      klass = Class.new do
        self.include Canvas::Pigment
        attr_accessor *definition['schema'].keys
        _base.set_class_instance_variables(self, :definition       => definition,
                                                 :schema           => definition['schema'],
                                                 :class_name       => definition['class_name'],
                                                 :_base            => _base,
                                                 :_attribute_types => {}

        )
      end
      _base.add_nested_classes(klass)
      _base.setup_attribute_type(klass)

      #############################################################
      # end of defining a new class and register this class under
      # Canvas
      const_set(definition['class_name'], klass)
    rescue => err
      self.logger(:error, err)
      raise ArgumentError.new('Failed to define the class!')
    end

    ###########################################################
    # add nested classes, and note a nested class under another
    # nested class will be defined under the main klass namespace
    #
    def add_nested_classes(klass)
      _base          = klass._base
      nested_classes = klass.definition['nested_classes'].map do |name, schema|
        raise "Error: Class #{name} is already registered!" if klass.const_defined?(name)
        nested_class = Class.new do
          self.include Canvas::Pigment
          attr_accessor *schema.keys
          _base.set_class_instance_variables(self, :schema           => schema,
                                                   :class_name       => name,
                                                   :_base            => klass,
                                                   :_attribute_types => {}

          )
        end
        klass.const_set(name, nested_class)
      end
      nested_classes.each {|sub_class| _base.setup_attribute_type(sub_class) }
    end

    #############################################################
    # setup the class's instance variables and define a getter for
    # it
    #
    def set_class_instance_variables(klass, variables)
      variables.each do |key, value|
        klass.instance_variable_set("@#{key}", value)
        klass.define_singleton_method(key) { instance_variable_get("@#{key}") }
      end
    end

    #############################################################
    # setup the type for each attribute in a class
    #
    def setup_attribute_type(klass)
      klass.schema.each do |attribute, config|
        types = config.scan(/\w+/)
        self.setup_layer_type(klass, types, 0)
        klass._attribute_types[attribute] = types
      end
    end

    #############################################################
    # setup the type for each layer in an attribute
    #
    def setup_layer_type(klass, types, layer_index)
      type = types[layer_index]
      return if type.nil?
      # Object is a keyword that objects of Object type can be applied to any classes
      return (types[layer_index] = Object) if type == 'Object'

      types[layer_index] = self.other_type(klass, type)
      # go to setup the next layer
      self.setup_layer_type(klass, types, layer_index + 1)
    end

    #############################################################
    # try to find the corresponding class type
    #
    def other_type(klass, type)
      case
        when Object.const_defined?(type)     ; Object.const_get(type)
        when klass.const_defined?(type)      ; klass.const_get(type)
        when klass._base.const_defined?(type); klass._base.const_get(type)
        else
          raise ArgumentError.new("Failed to find the definition for #{type}!")
      end
    end

  end
end