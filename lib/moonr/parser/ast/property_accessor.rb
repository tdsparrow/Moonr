module Moonr
  class PropertyAccessor < ASTElem
    def jseval(context, strict = false)
      @context = context
      @strict = strict
      
      @arg[0] = @arg.first.jseval context
      @arg.inject do |base, subscription|
        base_value = base.get_value
        prop_ref = subscription.is_a?(ASTElem) ? subscription.jseval(context) : subscription
        prop_value = prop_ref.get_value
        
        JSBaseObject.check_coercible base_value

        prop_name = prop_value.to_s
        JSReference.new base_value, prop_name
      end
      
    end

  end
end
