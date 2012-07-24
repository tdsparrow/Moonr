module Moonr
  class ObjEnvRec
    def initialize(obj)
      @obj = obj
    end

    def has_binding?(name)
      @obj.has_property(name)
    end

    def create_mutable_binding(name, configurable)
      raise if @obj.has_property(name)
      @obj.def_own_property name, PropDescriptor.new(:value => Undefined,
                                                     :writable => true,
                                                     :enumerable => true,
                                                     :configurable => configurable), true

    end

    def set_mutable_binding(name, value, strict)
      @obj.put name, value, strict
    end

    def get_binding_value(name, strict)
      value = @obj.has_property(name)
      
      if value
        @obj.get(name)
      else
        throw ReferenceError
      end
    end
  end

  class DeclEnvRec
    def initialize
      @bindings = {}
    end
    def has_binding?(name)
      @bindings[name]
    end
  end

  class LexEnv
    attr_accessor :rec, :outter
    def self.get_id_ref(lex, name, strict)
      return JSReference.new(Undefined, name, strict) if lex.null?
      
      env_rec = lex.rec
      exists = env_rec.has_binding? name

      return JSReference.new(env_rec, name, strict) if exists
      get_id_ref(lex.outter, name, strict)
    end

    def initialize
      yield self if block_given?
    end

    # create the global env #10.2.3
    # the global object could be different from spec
    def self.global(obj)
      self.new { |lex|
        lex.rec = ObjEnvRec.new obj
        lex.outter = Null

        # NIS (not in spec)
        obj.global=lex
      }
    end

    def self.new_decl_env(lex_env)
      self.new { |lex|
        env_rec = DeclEnvRec.new
        lex.rec = env_rec
        outter = lex_env
      }
    end
  end



  class ExecuteContext
    attr_accessor :lexical_env, :variable_env, :this_bind
    
    def decl_bind_init(code)
      env = variable_env.rec
      
      configurable_binding = false
      strict = false
      case code.code_type
      when :eval
        configurable_binding = true
      when :func
        raise
      end
      
      strict = code.strict?

      code.func_decls.each { raise }

      arguments_already_declared = env.has_binding? "arguments"

      if code.code_type == :func and arguments_already_declared
        raise
      end

      code.variable_decl_all.each do |var|
        var.each_id do |dn|
          unless env.has_binding? dn
            env.create_mutable_binding dn, configurable_binding
            env.set_mutable_binding dn, Undefined, strict
          end
        end
        
      end
    end

    def self.enter_func_code(scope, code, this_arg, arg_list)
      context = self.new
      if code.strict?
        context.this_bind = this_arg
      elsif this_arg.null? || this_arg.undefined?
        context.this_bind = scope.global
        #elsif type(this_arg) is not Object
      else
        context.this_bind = this_arg
      end
      local_env = LexEnv.new_decl_env scope
      context.lexical_env = local_env
      context.variable_env = local_env
      context
    end
  end

  class GlobalContext < ExecuteContext
    def initialize
      global = GlobalObject.new
      env = LexEnv.global global
      @lexical_env = env
      @variable_env = env
      @this_bind = global
    end
  end
end
