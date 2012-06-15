require 'singleton'
require 'forwardable'

module Moonr
  module Property
    
    def internal_property(prop, value)
      @internal_properties ||= []
      
      @internal_properties << [prop, value]
      define_method(prop) do
        @internal_properties[prop]
      end

      define_method(prop.to_s+"=") do |arg|
        @internal_properties[prop] = arg
      end
      
    end

    def property(prop, value = nil)
      @obj_properties ||= {}
      @obj_properties[prop] = value
    end

    def create_properties
      @obj_properties ||= {}
      @obj_properties.inject({}) { |ret, v| ret.merge(v.first => v.last) } if @obj_properties.size > 0
    end

    def create_internal_properties
      @internal_properties ||= []
      @internal_properties.inject({}) { |ret, v| ret.merge(v.first=>v.last) } if @internal_properties.size > 0
    end
  end

  module CheckType
    def undefined?
      nil?
    end

    def is_data?
      return false if undefined?
      return false if value.nil? and writable.nil?
      true
    end

    def null?
      is_a? JSNull
    end

    def is_accessor?
      return false if undefined?
      return false if get.nil? and set.nil?
      true
    end

    def is_generic?
      return false if undefined?
      return true if not is_data? and not is_accessor?
      false
    end
    
  end

  class JSUndefined_delete
    include CheckType
    include Singleton

    class << self
      alias :inst :instance
    end
  end


  class PropDescriptor
    extend Property
    include CheckType
    include Enumerable
    extend Forwardable

    def_delegator :@internal_properties, :each, :each

    internal_property :value, nil
    internal_property :set, nil
    internal_property :get, nil
    internal_property :writable, false
    internal_property :enumerable, false
    internal_property :configurable, false
    
    def initialize(hash)
      @internal_properties = self.class.create_internal_properties.merge(hash)
    end

    def merge!(other)
      other.each { |k,v| @internal_properties[k] = v if not v.nil? }
    end

    def copy
      desc = self.dup
      value || desc.value = nil
      get || self.get = nil
      set || self.set = nil
      writable || desc.writable = false
      enumerable || desc.enumerable = false
      configurable || desc.configurable = false
      desc
    end
    
  end
  
  class JSDataDescriptor < Struct.new(:value, :writable, :enumerable, :configurable)
    include CheckType

    def copy
      desc = self.dup
      value || desc.value = nil
      writable || desc.writable = false
      enumerable || desc.enumerable = false
      configurable || desc.configurable = false
      desc
    end
  end
  
  JSAccessorDescriptor = Struct.new(:get, :set, :writable, :enumerable, :configurable)


  class JSNull
    include CheckType
    include Singleton

    class << self
      alias :inst :instance
    end
  end
  
  class JSDataDescriptor

  end

  class JSAccessorDescriptor
    include CheckType

    def copy
      desc = self.dup
      get || self.get = Undefinded.inst
      set || self.set = Undefinded.inst
      writable || self.writable = false
      enumerable || self.enumerable = false
      configurable || self.configurable = false
    end
  end
  
  class JSPropIdentifier
    attr_reader :name, :desc
    
    def initialize(name, desc)
      @name, @desc = name, desc
    end

  end
end
