module Moonr
  class JSFunction < JSBaseObject
    def self.prototype
      proto = JSFunction.new
      proto.prototype = JSObject.prototype
      proto.put :length, 0, false
    end

    internal_property :clazz, "Function"
    internal_property :prototype, JSFunction.prototype
    internal_property :extensible, true

    property :length

    def initialize
      super()
    end

    
  end
end
