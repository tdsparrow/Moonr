module Moonr

  class GlobalObject < JSBaseObject
    internal_property :prototype, Null
    internal_property :extensible, true

    property :Function, PropDescriptor.new(:value => Function.new,
                                            :writable => true,
                                            :enumerable => false,
                                            :configurable => true)
    
    def global=(lex)
      get(:Function).global=lex
    end
  end
end

