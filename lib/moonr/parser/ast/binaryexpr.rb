module Moonr
  class BinaryExpr < ASTElem
    def jseval(env)
      expr[0] = expr.first.jseval(env)
      
      expr.inject do |prev, op|
        lvalue = prev.get_value
        prev = op.jseval(lvalue, env)
      end
    end
  end
end
