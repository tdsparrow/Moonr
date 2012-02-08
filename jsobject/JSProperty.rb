module Moonr
  JSDataDescriptor = Struct.new(:value, :writable, :enumerable, :configurable)
  JSAccessorDescriptor = Struct.new(:get, :set, :writable, :enumerable, :configurable)

  class JSPropIdentifier
    attr_reader :name, :desc
    
    def initialize(name, desc)
      @name, @desc = name, desc
    end

  end
end
