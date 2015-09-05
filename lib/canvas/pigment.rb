require 'canvas/color'
module Canvas
  module Pigment
    include Color
    BUILT_IN_TYPES = %w(String Integer Float Symbol)
    def initialize(params = {})
      params ||= {}
      params   = params.to_hash if params.is_a?(self.class)
      self.dump(params)
    end

    def dump(params)
      params = params.with_indifferent_access
      self.class.schema.each_key do |attribute|
        self.assign_attribute_value(attribute, params[attribute])
      end
      params
    end
    protected

    #############################################################
    # assign the value to the object at the attribute level
    #
    def assign_attribute_value(attribute, value)
      config = self.class.schema[attribute]
      types  = (self.class.type_cache[attribute] ||= config.scan(/\w+/))
      begin
        value = self.assign_layer_value(value, types, 0)
        self.instance_variable_set("@#{attribute}", value)
      rescue ArgumentError => err
        Canvas.logger.(:error, err)
        raise ArgumentError.new("attribute for #{self.class.class_name}: #{attribute} should be #{config}")
      end
    end

    def assign_layer_value(value, types, layer_index)
      type = types[layer_index]
      # Object is a keyword that objects of Object type can be applied to any classes
      return value if type.nil? || type == 'Object'
      value = self.type_check(value, type)
      case type
        when *BUILT_IN_TYPES then self.built_in_type_assignment(type, value)
        when 'Hash'          then (value || HashWithIndifferentAccess.new)
        when 'Array'
          return [] if value.nil?
          raise ArgumentError.new('Non-array value given for an array field!') unless value.is_a?(Array)
          value.map{|v| self.assign_layer_value(v, types, layer_index + 1)}
        else self.find_class_and_assign_value(type, value)
      end
    end

    #############################################################
    # nested class has the highest priority, then comes the
    # classes defined within Canvas followed by the classes
    # defined in Object
    #
    def find_class_and_assign_value(type, value)
      if (sub_class = self.class.nested_classes_mapping[type])
        sub_class.new(value)
      elsif Canvas.const_defined?(type)
        Canvas.const_get(type).new(value)
      elsif Object.const_defined?(type)
        Object.const_get(type).new(value)
      else
        value
      end
    end

    def type_check(value, type)
      return value if value.nil? || Object.const_defined?(type) && value.is_a?(Object.const_get(type))
      return value if self.class.respond_to?(:nested_classes) && self.class.nested_classes[type] && value.is_a?(self.class.nested_classes_mapping[type])
      return value if Canvas.const_defined?(type) && value.is_a?(Canvas.const_get(type))
      raise ArgumentError.new('wrong type when assigning value')
    end

    def built_in_type_assignment(type, value)
      value ? value : nil
    end
  end
end