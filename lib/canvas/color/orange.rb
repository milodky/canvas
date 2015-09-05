module Canvas
  module Color
    module Orange
      ###########################################################
      # overload the [] operator
      #
      def [](attribute)
        self.instance_variable_get("@#{attribute}")
      end

      ###########################################################
      # overload the []= operator
      #
      def []=(attribute, value)
        # shall I raise an exception?
        return if self.class.schema[attribute].nil?
        # shall I convert the value if it's not in the right format?
        self.instance_variable_set("@#{attribute}", value)
      end

      ###########################################################
      # turn the object into a hash
      #
      def to_hash
        HashWithIndifferentAccess.new.tap do |hash|
          self.class.schema.each_key do |key|
            next if (value = self[key]).blank?
            hash[key] =
                case value
                  when Array; value.map {|item| item.respond_to?(:to_hash) ? item.to_hash : item }
                  else      ; value.respond_to?(:to_hash) ? value.to_hash : value
                end
          end
        end
      end

      ###########################################################
      # the same as to_hash, compatible with some other modules
      #
      alias :attributes :to_hash
      alias :as_hash    :to_hash

      ###########################################################
      # used in used uniq
      #
      def hash
        self.respond_to?(:id) && self.id ? self.id.to_i : self.to_hash.hash
      end

      ###########################################################
      # check if two objects are the same or not
      #
      def eql?(other)
        return false if self.class != other.class
        self.to_hash == (other.respond_to?(:to_hash) ? other.to_hash : nil)
      end

      alias :== :eql?
    end
  end
end