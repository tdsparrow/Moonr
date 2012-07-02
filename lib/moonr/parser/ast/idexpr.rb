module Moonr
  
  class IdExpr < ASTElem
    def jseval(context, strict = false)
      env = context.lexical_env
      LexEnv.get_id_ref(env, id, strict)
    end
  end
end
