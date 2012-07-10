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
  

  class JSFunction < JSBaseObject
    extend Objective
    
    internal_property :clazz, 'Function'
    internal_property :prototype, FunctionPrototype
    internal_property :extensible, true
    internal_property :call, nil
    internal_property :formal_param, JSList.empty
    internal_property :code, JSSources.empty

    property :length

    def initialize param, body, env, strict
      super()
      self.formal_param = param
      self.code = body
      create_function env
    end

    def formal_param= args
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
    
    def self.clazz
      'Function'
    end
    
    def self.prototype
      FunctionPrototype
    end
    
    def self.extensible
      true
    end

    def self.call *args
      self.new GlobalEnv, *args
    end

    def self.constructor *args
      self.new GlobalEnv, *args
    end

    private
    def create_function env
      def_own_property :length, PropDescriptor.new(:value => formal_param.length), false
      
      proto = JSObject.new
      proto.def_own_property :constructor, PropDescriptor.new(:value => self,
                                                              :writable => true,
                                                              :configurable => true), false
      
      def_own_property :prototype, PropDescriptor.new(:value => proto,
                                                      :writable => true), false
    end

    
  end

  FunctionPrototype.instance_eval {

    def_own_property(:constructor, PropDescriptor.new(:value => JSFunction), false)

    #apply = JSFunction.new 'apply'
    #def_own_property(:apply, PropDescriptor.new(:value => apply), false)
  }

end
