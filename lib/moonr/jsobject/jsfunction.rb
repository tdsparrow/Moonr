require 'moonr/jsobject/jslist'
require 'moonr/jsobject/jssources'

module Moonr
  

  FunctionPrototype = JSBaseObject.new {
    def clazz 
      'Function'
    end

    def call *args
      Undefined
    end

    def prototype
      ObjectPrototype
    end

    def extensible
      true
    end

    def_own_property(:length, PropDescriptor.new(:value => 0), false)
    
  }

  # 
  #
  class Function < JSBaseObject
    attr_accessor :global

    internal_property :clazz, 'Function'
    internal_property :prototype, FunctionPrototype
    
    property :prototype, PropDescriptor.new(:value => FunctionPrototype, 
                                            :writable => false,
                                            :enumerable => false,
                                            :configurable => false)

    property :length, PropDescriptor.new(:value => 1,
                                         :writable => false,
                                         :enumerable => false,
                                         :configurable => false)
    
    def call *args
      arg_count = args.length
      p = ""
      body = ""

      if arg_count == 1
        body = args[0]
      elsif arg_count > 1
        p = args[0..-2].join(',')
        body = args.last
      end

      p = Parser.parse_partial :formal_parameter_list, p
      body = Parser.parse_partial :function_body, body
      strict = body.strict?

      # miss strict check
      JSFunction.new p, body, global, strict
    end
    
    alias :construct :call
  end

  

  class JSFunction < JSBaseObject
    extend Objective
    
    internal_property :clazz, 'Function'
    internal_property :prototype, FunctionPrototype
    internal_property :extensible, true
    internal_property :call, nil
    internal_property :formal_param, JSList.empty
    internal_property :code, Sources.empty
    internal_property :scope, Undefined

    property :length

    def initialize(param, body, scope, strict)
      super()
      self.formal_param = param
      self.code = body
      create_function scope
    end

    def formal_param=(args)
      @internal_properties[:formal_param] = args.join(',').split(',')
    end

    def code= body
      @internal_properties[:code] = body.is_a?(String) ? Parser.parse_partial(:function_body, body) : body
    end

    def get(proto)
      v = super(proto)
      throw TypeError if proto == :caller and strict?
      return v
    end

    def call(this, arg_list)
      funcCtx = ExecuteContext.enter_func_code scope, code, this, arg_list
      result = if code.eql?(Sources.empty) 
                 Result.new :type => :normal, :value => Undefined, :target => :empty
               else
                 code.jseval funcCtx
               end
      
      # miss exception throw
      result.type == :return ? result.value : Undefined
    end

    def construct(param, context, strict)
      obj = JSObject.new
      proto = obj.get :prototype
      obj.prototype = proto.is_a?(JSObject) ? proto : ObjectPrototype
      result = call(obj, param)
      
      return result.is_a?(JSObject) ? result : obj
    end

    private
    def create_function scope
      @internal_properties[:scope] = scope
      def_own_property :length, PropDescriptor.new(:value => formal_param.length,
                                                   :writable => false,
                                                   :enumerable => false,
                                                   :configurable => false), false
      
      proto = JSObject.new
      proto.def_own_property :constructor, PropDescriptor.new(:value => self,
                                                              :writable => true,
                                                              :configurable => true), false
      
      def_own_property :prototype, PropDescriptor.new(:value => proto,
                                                      :writable => true), false
    end
    
  end

  FunctionPrototype.instance_eval do

    def_own_property(:constructor, PropDescriptor.new(:value => JSFunction), false)

    apply = JSFunction.new %w{this_arg arg_array}, nil, nil, false
    apply.instance_eval do
      undef :construct

      def call(this_arg, arg_array)
        func = this_arg
        this = arg_array.first
        arg = arg_array.last
        raise TypeError unless func.respond_to :call
        
        if arg.null? || arg.Undefined?
          return func.call(this, nil)
        end
        raise TypeError unless arg.is_a? JSObject

        len = arg.get :length
        arg_list = JSList.new
        (1..len-1).each { |ind| arg_list << arg.get(ind.to_s) }
        func.call this, arg_list
      end
    end
    def_own_property(:apply, PropDescriptor.new(:value => apply), false)

    bind = JSFunction.new %w{thisArg ...}, nil, nil, false
    def_own_property(:bind, PropDescriptor.new(:value => bind), false)    

    call = JSFunction.new %w{thisArg ...}, nil, nil, false
    def_own_property(:call, PropDescriptor.new(:value => call), false)    
  end

end
