module Moonr
  class UnaryExpr < ASTElem
    register_op :delete, :delete
    register_op :void, :void
    register_op :typeof, :typeof
    register_op :'++', :plusplus
    register_op :'--', :minusminus
    register_op :'+', :plus
    register_op :'-', :minus
    register_op :'~', :bit_not
    register_op :'!', :not

    def jseval(context)
      eval_op(context, op, operant)
    end

    def delete(context, operant)
      ref = operant.jseval context
      return true unless ref.is_a? JSReference

      if ref.is_unresolvable_ref?
        raise SyntaxError if ref.is_strict_ref?
        return true
      end

      if ref.is_property?
        return ref.base.to_obj.delete name, ref.is_strict_ref?
      else
        raise SyntaxError if ref.is_strict_ref?
        bindings = ref.base
        bindings.delete_binding ref.name
      end
    end

    def void(context, operant)
      expr = operant.jseval context
      expr.get_value
      Undefined
    end

    def typeof(context, operant)
      val = operant.jseval context
      
      if val.is_a? JSReference
        return "undefined" if val.is_unresolvable_ref?
        val = val.get_value
      end

      {
        Undefined => 'undefined',
        Null => 'object',
        Boolean => 'boolean',
        Number => 'number',
        String => 'string',
        JSBaseObject => 'object',
        JSFunction => 'function'
      }[val.jstype]
    end

    def plusplus(context, operant)
      expr = operant.jseval context
      
      strict_ref_check expr

      old_val = expr.get_value
      new_val = old_val + 1
      expr.put_value new_val
      new_val
    end

    def minusminus(context, operant)
      expr = operant.jseval context
      
      strict_ref_check expr
        
      old_val = expr.get_value
      new_val = old_val - 1
      expr.put_value new_val
      new_val
    end

    def plus(context, operant)
      expr = operant.jseval context
        
      expr.get_value
    end

    def minus(context, operant)
      expr = operant.jseval context
        
      -expr.get_value
    end

    def bit_not(context, operant)
      expr = operant.jseval context
      ~expr.get_value
    end

    def not(context, operant)
      expr = operant.jseval context
      !expr.get_value
    end

    def strict_ref_check(expr)
      if expr.is_a?(JSReference) &&
          expr.is_strict_ref? &&
          expr.base.is_a?(EnvRec) &&
          %w(eval arguments).include?(expr.name) then
        raise SyntaxError
      end
    end

    
  end
end
