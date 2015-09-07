module Canvas
  module Crayon
    def initialize!(path, base_class = nil)
      definition = (path.is_a?(Hash) ? path : YAML.load_file(path)).with_indifferent_access
      # a class may not have any nested classes
      definition['configuration'] ||= {}
      base_module                   = self
      base                          = base_class || base_module
      #############################################################
      # define a new class
      #
      klass = Class.new do
        self.include Canvas::Pigment
        attr_accessor *definition['schema'].keys

        base_module.send(:set_class_instance_variables, *[self, {
                                                                  :definition       => definition,
                                                                  :schema           => definition['schema'],
                                                                  :_base            => base,
                                                                  :_attribute_types => {}
                                                                }
                                                          ]
        )
      end

      #############################################################
      # end of defining a new class and register this class under
      # Canvas
      base.const_set(definition['class_name'], klass)
      return klass if base_class

      base_module.add_nested_classes(klass)
      base_module.setup_attribute_type(klass)
    rescue => err
      self.logger(:error, err)
      raise ArgumentError.new('Failed to define the class!')
    end
    protected
    ###########################################################
    # add nested classes, and note a nested class under another
    # nested class will be defined under the main klass namespace
    #
    def add_nested_classes(klass)
      (klass.definition['nested_classes'] || {}).map do |name, schema|
        initialize!({:class_name => name, :schema => schema}, klass)
      end.each {|sub_class| klass._base.setup_attribute_type(sub_class) }
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
      klass.schema.each do |attr, config|
        klass._attribute_types[attr] = self.setup_layer_type(klass, config.scan(/\w+/), 0)
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

      types[layer_index] = self.final_type(klass, type)
      # go to setup the next layer
      self.setup_layer_type(klass, types, layer_index + 1)
      types
    end

    #############################################################
    # try to find the corresponding class type
    #
    def final_type(klass, type)
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