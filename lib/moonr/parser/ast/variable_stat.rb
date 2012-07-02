module Moonr
  class VariableStat < ASTElem
    def append another
      @list ||= []
      @list << another
      self
    end

    def jseval(env)

      idexpr = IdExpr.new :id => id
      lhr = idexpr.jseval env
      
      rhs = initialiser.jseval env
      value = rhs.get_value

      lhr.put_value value
      p lhr

      @list && @list.inject(lhr) do |stat|
        stat.jseval env
      end
      Result.new :type => :normal, :value => :empty, :target => :empty
    end
  end
end
