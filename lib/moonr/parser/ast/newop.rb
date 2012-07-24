module Moonr
  class NewOp < ASTElem
    def jseval(context, strict=false)
      ref = constructor.jseval context, strict
      construct = ref.get_value

      raise TypeError if not construct.is_a? JSBaseObject
      raise TypeError if not construct.respond_to? :construct
      
      construct.construct argu, context, strict
    end
  end
end
