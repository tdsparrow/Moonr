module Moonr

  class Function < JSBaseObject
    internal_property :clazz, 'Function'
    internal_property :prototype, FunctionPrototype
    
    property :prototype, PropDescriptor.new(:value => FunctionPrototype, 
                                            :writable => false,
                                            :enumerable => false,
                                            :configurable => false)

    property :length, PropDescriptor.new(:value => 1,
                                         :writable => false,
                                         :enumerable => false,
                                         :configurable => false)
    
    def call *args
      JSFunction.new
    end
  end

  class GlobalObject < JSBaseObject
    internal_property :prototype, Null
    internal_property :extensible, true

    property :Function, Function.new
  end
end
