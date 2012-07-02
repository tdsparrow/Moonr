module Moonr
  class ExprStat < ASTElem
    def jseval(env)
      expr_ref = expr.jseval(env)
      Result.new :type => :normal, :value => expr_ref.get_value, :target => :empty
    end

    def is_string?
      expr.expr.length == 1 and expr.expr[0].is_a? String
    end
  end
end
