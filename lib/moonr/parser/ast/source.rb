module Moonr
  class Sources < ASTElem
    attr :code_type
    def jseval(env)
      env.decl_bind_init(self)
      Result.new :type => :normal, :value => :empty, :target => :empty if @arg.empty?
      
      # starting to eval source elements
      @arg.inject(nil) do |head_result, stat|
        return head_result if head_result and head_result.abrupt?

        tail_result = stat.jseval(env)
        value = (head_result and tail_result.value == :empty) ? head_result.value : tail_result.value

        head_result = Result.new :type=> tail_result.type, :value => value, :target => tail_result.target
      end
    end

    def func_decls
      @arg.select { |node| node.is_a? FuncDeclStat }
    end

    def variable_decl_all
      @arg.select { |node| node.is_a? VariableStat }
    end

    def strict?
      @strict ||= check_strict
      @strict == true
    end

    def check_strict
      @arg.each do | stat |
        return false if not stat.is_string?
        return true if stat.jseval(nil).value == "use strict"
      end
    end
  end
end
