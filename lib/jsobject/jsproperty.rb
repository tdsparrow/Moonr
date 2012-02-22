module Moonr
  module CheckType
    def undefined?
      is_a? Undefined
    end

    def is_data?
      is_a? JSDataDescriptor
    end

    def is_accessor?
      is_a? JSAccessorDescriptor
    end
  end
  JSDataDescriptor = Struct.new(:value, :writable, :enumerable, :configurable)
  JSAccessorDescriptor = Struct.new(:get, :set, :writable, :enumerable, :configurable)

  class JSDataDescriptor
    include CheckType
  end

  class JSPropIdentifier
    attr_reader :name, :desc
    
    def initialize(name, desc)
      @name, @desc = name, desc
    end

  end
end
