module Moonr
  class NaN
  end

  class ::Object
    def null?
      self.is_a?(NilClass) || self.equal?(Null)
    end

    def undefined?
      (! self.is_a?(NilClass) ) and self.equal?(Undefined)
    end
  end
  
  module Objective

    def get(prop)
      desc = get_property(prop)
      return Null if desc.undefined?
      return desc.value if desc.is_data?

      getter = desc.get
      return Null if getter.null?

      return getter.call(self)
    end

    def get_property(prop)
      prop = get_own_property(prop)
      return prop unless prop.undefined?

      proto = prototype
      # nil? or null?
      return Undefined if proto.null?

      return proto.get_property(prop)
    end


    def has_property(prop)
      desc = get_property(prop)
      desc != Undefined
    end
    
    def get_value
      self
    end

    def get_own_property(prop)
      return Undefined unless @properties[prop]
      return @properties[prop]
    end

    def def_own_property(name, desc, to_throw)
      current = get_own_property(name)
      p current
      reject if current.undefined? and not extensible
      
      if current.undefined? and extensible
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

    def put(prop, value, to_throw)
      raise TypeError if not can_put(prop) and to_throw
      return if not can_put(prop)

      own_desc = get_own_property(prop)
      if own_desc.is_data?
        Log.debug "Put new value for #{prop}"
        value_desc = PropDescriptor.new(:value => value)
        def_own_property(prop, value_desc, to_throw)
        return
      end

      desc = get_property(prop)

      if desc.is_accessor?
        desc.set self, value
      elsif
        new_desc = PropDescriptor.new(:value => value,
                                      :writable => true,
                                      :enumerable => true,
                                      :configurable => true)
        def_own_property(prop.new_desc, to_throw)
      end
        
    end

    def can_put(prop)
      desc = get_own_property(prop)

      if not desc.undefined?
        if desc.is_accessor?
          return false if desc.set.undefined?
          return true
        end

        return desc.writable
      end 

      proto = prototype
      return extensible if proto.null?

      inherited = proto.get_property(prop)
      return extensible if inherited.undefined?

      if inherited.is_accessor?
        return false if inherited.set.undefined?
        return true
      else
        return false if extensible
        return inherited.writable
      end
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

  end

  class JSString < JSBaseObject
  end

  class JSNumber < JSBaseObject
  end

  class JSBoolean < JSBaseObject
  end

  Undefined = JSBaseObject.new
  def Undefined.method_missing(sym, *args, &block)
    Null
  end
  Null = JSBaseObject.new

  def Null.method_missing(sym, *args, &block) 
    Null
  end
  
end
