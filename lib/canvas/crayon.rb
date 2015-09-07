require 'canvas/pigment'
require 'yaml'
module Canvas
  module Pigment
    def initialize!(path)
      definition = path.is_a?(Hash) ? path : YAML.load_file(path).with_indifferent_access
      class_name = definition['class_name']
      # a class may not have any nested classes
      definition['nested_classes'] ||= {}
      definition['configuration']  ||= {}
      self.add_timestamp(definition)

      #############################################################
      # define a new class
      #
      klass = Class.new do
        self.include Canvas::Pigment
        attr_accessor *definition['schema'].keys
        Canvas.set_class_instance_variables(self, :definition             => definition,
                                                  :schema                 => definition['schema'],
                                                  :nested_classes         => definition['nested_classes'],
                                                  :class_name             => definition['class_name'],
                                                  :type_cache             => {},
                                                  # shared by its sub classes
                                                  :nested_classes_mapping => {}
        )

        ###########################################################
        # add nested classes, and note a nested class under another
        # nested class will be defined under the main klass namespace
        #
        def self.add_nested_classes
          nested_classes         = self.nested_classes
          nested_classes_mapping = self.nested_classes_mapping
          nested_classes.each do |name, schema|
            raise "Error: Class #{name} is already registered!" if nested_classes_mapping[name]
            klass = Class.new do
              self.include Canvas::Pigment

              attr_accessor *schema.keys
              Canvas.set_class_instance_variables(self, :schema                 => schema,
                                                        # shared by other nested classes under the same namespace
                                                        :nested_classes_mapping => nested_classes_mapping,
                                                        :nested_classes         => nested_classes,
                                                        :class_name             => name,
                                                        :type_cache             => {}
              )

            end
            nested_classes_mapping[name] = klass
            self.const_set(name, klass)
          end
        end
      end
      klass.add_nested_classes

      #############################################################
      # end of defining a new class and register this class under
      # Canvas
      const_set(class_name, klass)
    rescue => err
      Canvas.logger(:error, err)
      raise ArgumentError.new('Failed to define the class!')
    end

    def add_timestamp(definition)
      return unless definition['configuration']['auto_timestamp']
      definition['schema'].merge!('updated_at' => 'String', 'created_at' => 'String')
    end

    ###############################################################
    # setup the class's instance variables and define a getter for
    # it
    #
    def set_class_instance_variables(klass, variables)
      variables.each do |key, value|
        klass.instance_variable_set("@#{key}", value)
        klass.define_singleton_method(key) { instance_variable_get("@#{key}") }
      end
    end
  end
end