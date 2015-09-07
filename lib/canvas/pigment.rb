require 'canvas/color'
module Canvas
  module Pigment
    include Color
    BUILT_IN_TYPES = [String, Integer, Float, Symbol]
    #############################################################
    # when given an object, it tries to convert it into a hash
    # first
    #
    def initialize(params = {})
      params ||= {}
      params   = params.try(:to_hash) || params if params.is_a?(self.class)
      self.dump(params)
    end

    #############################################################
    # used for checking if the params are correct or not
    #
    def dump(params)
      params = params.with_indifferent_access
      self.class.schema.each_key { |attribute| self.assign_attribute_value(attribute, params[attribute]) }
      params
    end
    protected

    #############################################################
    # assign the value to the object at the attribute level
    #
    def assign_attribute_value(attribute, value)
      types = self.class._attribute_types[attribute]
      value = self.assign_layer_value(value, types, 0)
      self.instance_variable_set("@#{attribute}", value)
    rescue => err
      Canvas.logger(:error, err)
      raise ArgumentError.new(" #{attribute} for #{self.class.class_name} should be kind of #{types.join("#")}, but got #{value.class}")
    end

    def assign_layer_value(value, types, layer_index)
      type = types[layer_index]
      # Object is a keyword that objects of Object type can be applied to any classes
      return value if type.nil? || type == Object
      value = self.check_layer_type(value, type)
      case
        when BUILT_IN_TYPES.include?(type) then self.built_in_type_assignment(type, value)
        when Hash  == type                 then (value || HashWithIndifferentAccess.new)
        when Array == type
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
      type.new(value) unless value.nil?
    end

    def check_layer_type(value, type)
      return value if value.nil? || value.is_a?(type) || value.is_a?(Hash) || value.is_a?(Array)
      raise ArgumentError.new("Wrong type when assigning value for #{type}")
    end

    def built_in_type_assignment(type, value)
      return value if value.nil? || value.is_a?(type)
      raise ArgumentError.new("Wrong type when assigning value for #{type}")
    end
  end
end