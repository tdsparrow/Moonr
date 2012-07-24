module Moonr
  class ObjectLiteral < ASTElem
    def jseval(context, strict = false)
      @context = context
      @strict = strict
      obj = JSObject.new
      @arg.inject(obj) do |obj, literal|
        prop_id = init literal
        previous = obj.get_own_property prop_id.name
        
        unless previous.undefined?
          if strict and previous.is_data? and prop_id.desc.is_data? or
              previous.is_data? and prop_id.is_accessor? or
              previous.is_accessor? and prop_id.is_data? or
              previous.is_accessor? and prop_id.is_accessor? and ( [ previous.get, prop_id.desc.get ].all? { |f| not f.nil? } or [ previous.set, prop_id.desc.set ].all? { |f| not f.nil? } )
            
            raise SyntaxError
          end
        end
      
        obj.def_own_property prop_id.name, prop_id.desc, false
        obj
      end
    end

    def init(initialiser)
      if initialiser.expr
        expr_value = initialiser.expr.is_a?(ASTElem) ? initialiser.expr.jseval(@context, @strict) : initialiser.expr
        prop_value = expr_value.get_value
        JSPropIdentifier.new initialiser.name, PropDescriptor.new( :value => prop_value, :writable => true, :enumerable => true, :configurable => true)
        
      elsif initialiser.get
        # miss strict code 
        closure = JSFunction.new [], initialiser.get, @context, @strict
        JSPropIdentifier.new initialiser.name, PropDescriptor.new( :get => closure, :enumerable => true, :configurable => true )
      elsif initialiser.set
        closure = JSFunction.new initialiser.param, initialiser.set, @context, @strict
        JSPropIdentifier.new initialiser.name, PropDescriptor.new( :set => closure, :enumerable => true, :configurable => true )
      end

    end
  end
end
