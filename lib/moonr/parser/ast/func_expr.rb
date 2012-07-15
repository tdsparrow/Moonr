module Moonr
  class FuncExpr < ASTElem
    def jseval context, strict=false
      JSFunction.new param, body, context.lexical_env, (strict || body.strict?)
    end
  end
end
