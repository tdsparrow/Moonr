module Moonr
  class ReturnStat < ASTElem
    def jseval(context)
      if value
        expr_ref = value.jseval context
        Result.new :type => :return, :value => expr_ref.get_value, :target => :empty
      else
        Result.new :type => :return, :value => Undefined, :target => :empty
      end
    end
  end
end
