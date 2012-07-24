module Moonr
  class FuncExpr < ASTElem
    def intialize(arg = {})
      super
      @body.parent = self
    end

    def jseval context, strict=false
      JSFunction.new param, body, context.lexical_env, (strict || body.strict?)
    end
  end
end
