module Moonr
  class BinaryOp < ASTElem
    def jseval(lvalue, context)
      @context = context;
      self.send(op.to_sym, lvalue)
    end

    def +(lvalue)
      lprim = to_prim lvalue
      rprim = to_prim right_operant.jseval(@context).get_value

      # todo complete Number implementation
      if lprim.is_a? String and rprim.is_a? String
        lprim + rprim
      else
        lprim + rprim
      end  
    end

    def to_prim(val)
      if [Undefined, Null].any?(&val.method(:equal?)) or [JSBoolean, Numeric, String ].any?(&val.method(:is_a?))
        val
      elsif val.is_a? JSObject
        val.default_value("PreferredType")
      else
        throw TypeError
      end
    end
  end
end
