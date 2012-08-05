module Moonr
  class FuncCall < ASTElem
    def jseval(context)
      ref = member_expr.jseval context


      argu.inject(ref) do |acc, argu|
        func = acc.get_value
        arg_list = argu.map { |expr| expr.jseval context }

        raise TypeError unless func.is_a? JSBaseObject
        raise TypeError unless func.is_callable?
        
        if acc.is_a?(JSReference) 
          if acc.is_property?
            this_value = acc.base
          else
            this_value = acc.base.implicit_this_value
          end
        else
          this_value = Undefined
        end
        
        acc = func.call this_value, arg_list
      end
    end
  end
end
