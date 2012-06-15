module Moonr
  class NaN
  end
  
  module Objective

    def get(prop)
      desc = get_property(prop)
      return nil  if desc.nil?
      return desc.value if desc.is_data?

      getter = desc.get
      return nil if getter.nil?

      return getter.call(self)
    end

    def get_property(prop)
      prop = get_own_property(prop)
      return prop unless prop.nil?

      proto = prototype
      # nil? or null?
      return nil if proto.null?

      return proto.get_property(prop)
    end

    
    def get_value
      self
    end

    def get_own_property(prop)
      return nil unless @properties[prop]
      return @properties[prop]
    end

    def def_own_property(name, desc, to_throw)
      current = get_own_property(name)

      reject if current.nil? and not extensible
      
      if current.nil? and extensible
        if desc.is_generic? or desc.is_data?
          @properties[name] = desc.copy
        else
          @properties[name] = desc.copy
        end

        return true
      end
      
      return true if desc.select {|k, v| not v.nil?}.empty?
      return true if desc == current

      unless current.configurable
        reject if desc.configurable
        reject if current.configurable == ! desc.configurable
      end

      unless desc.is_generic?
        if current.is_data? ^ desc.is_data?
          reject if not current.configurable

          # caused bu mysterious "absent" in ECMA 262 for property descriptor
          if current.is_data?
            current = PropDescriptor.new(:configurable => current.configurable,
                                         :enumerable => current.enumerable)
          else
            current = PropDescriptor.new(:configurable => current.configurable,
                                         :enumerable => current.enumerable)
          end
        elsif current.is_data? and desc.is_data?
          unless current.configurable
            reject if not current.writable and desc.writable

            if not current.writable
              reject if not desc.value.nil? and not same_value(desc.value, current.value)
            end
          end
        else
          if not current.configurable
            reject if not desc.set.nil? and not same_value(desc.set, current.set)
            reject if not desc.get.nil? and not same_value(desc.get, current.get)
          end
        end
      end
      
      current.merge!(desc)
      true
    end

  end

  class JSBaseObject
    extend Property
    include Objective

    def self.check_coercible param
      raise TypeError if param.nil?
      raise TypeError if param.is_a? JSNull
    end

    
    def initialize(&block)
      @properties = self.class.create_properties || {}
      @internal_properties = self.class.create_internal_properties || {}

      instance_eval(&block) if block_given?
    end

    def null?
      self.eql? Null
    end

  end

  class JSString < JSBaseObject
  end

  class JSNumber < JSBaseObject
  end

  class JSBoolean < JSBaseObject
  end

  Undefined = JSBaseObject.new
  Null = JSBaseObject.new
  
end
