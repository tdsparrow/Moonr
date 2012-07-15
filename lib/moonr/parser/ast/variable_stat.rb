module Moonr
  class VariableStat < ASTElem
    def append another
      @list ||= []
      @list << another
      self
    end

    def jseval(context)
      idexpr = IdExpr.new :id => id
      lhr = idexpr.jseval context
      
      if initialiser
        rhs = initialiser.jseval context
        value = rhs.get_value

        lhr.put_value value
      end
 
      @list && @list.inject(lhr) do |acc, stat|
        stat.jseval context
      end
      Result.new :type => :normal, :value => :empty, :target => :empty
    end

    def each_id
      yield id
      @list && @list.each { |var| yield var.id }
    end
  end
end
