module Moonr
  class ThisBind < ASTElem
    def jseval(env)
      env.this_bind
    end
  end
end
