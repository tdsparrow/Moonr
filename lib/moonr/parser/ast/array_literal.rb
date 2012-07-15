module Moonr
  class ArrayLiteral < ASTElem
    def jseval(context, strict = false)
      arr = JSArray.new
      @arg.inject(arr) do |arr, literal|
        pad = literal.elisions
        len = arr.get(:length)
        
        init_result = literal.elem.nil? ? nil : literal.elem.jseval(context)
        if init_result.nil?
          arr.put :length, pad+len, false
        else
          init_value = init_result.get_value
        
          arr.def_own_property (len+pad).to_s, PropDescriptor.new(:value => init_value,
                                                                  :writable => true,
                                                                :enumerable => true,
                                                                :configurable => true), false
        end
        
        arr
      end
    end
  end
end
