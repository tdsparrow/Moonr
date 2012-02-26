require 'singleton'

module Moonr
  module CheckType
    def undefined?
      is_a? JSUndefined
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
      return true if writable.nil? and value.nil?
      false
    end
    
  end
  
  class JSDataDescriptor < Struct.new(:value, :writable, :enumerable, :configurable)
    include CheckType

    
    def copy
      desc = self.dup
      value || self.value = Undefinded.inst
      writable || self.writable = false
      enumerable || self.enumerable = false
      configurable || self.configurable = false
    end
  end
  
  JSAccessorDescriptor = Struct.new(:get, :set, :writable, :enumerable, :configurable)

  class JSUndefined
    include CheckType
    include Singleton

    class << self
      alias :inst :instance
    end
  end

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
