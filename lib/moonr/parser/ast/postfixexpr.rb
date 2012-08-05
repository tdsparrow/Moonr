module Moonr
  class PostfixExpr < ASTElem

    register_op :'++', :plusplus
    register_op :'--', :minusminus

    def jseval(context)
      eval_op(context, op)
    end
    
    def plusplus(context)
      lhs = lvalue.jseval context
      
      # todo SyntaxError check
      old_value = lhs.get_value.to_i
      new_value = old_value + 1
      lhs.put_value new_value
      old_value
    end

    def minusminus(context)
      lhs = lvalue.jseval context

      # todo SyntaxError check
      old_value = lhs.get_value.to_i
      new_value = old_value - 1
      lhs.put_value new_value
      old_value
    end
  end
end
