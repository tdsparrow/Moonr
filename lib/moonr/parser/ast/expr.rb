module Moonr
  class Expr < ASTElem
    def jseval(env)
      expr.inject(nil) do |prev, e|
        ref = e.is_a?(ASTElem) ? e.jseval(env) : e
        prev = ref.get_value
      end
    end
  end
end
