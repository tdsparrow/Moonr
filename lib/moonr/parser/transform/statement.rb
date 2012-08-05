module Moonr
  class Stms < Parslet::Transform
    
    # this
    rule(:this => simple(:this) ) { ThisBind.new }

    rule(:primary_expr => simple(:prime)) { prime }

    rule(:identifier => simple(:id) )do
      IdExpr.new :id => id.to_s
    end

    # Array initialiser
    rule(:elision => simple(:e) ) { e.to_s.count(',') }
    rule(:elisions => simple(:e) ) do 
      OpenStruct.new :elisions => e.nil? ? 0:e, :elem => nil
    end

    # [ , , , ]
    rule(:al => simple(:al), :elisions => simple(:e), :ar => simple(:ar) ) do
      len = e.nil? ? 0:e
      OpenStruct.new :elisions => len, :elem => nil
      #JSArray.new(len)
    end
    
    rule(:elisions => simple(:e), :assignment => simple(:a) ) do
      ind = e.nil? ? 0 : e
      OpenStruct.new :elisions => ind, :elem => a 
      #obj = JSArray.new(ind) 
      #obj.def_own_property(ind.to_s, PropDescriptor.new(:value => a, :writable => true, :enumerable => true, :configurable => true), false )
      #obj
    end

    rule(:array_literal => sequence(:a) ) do
      ArrayLiteral.new a
      # ret = a.inject do |total, value|
      #   if value.is_a? Fixnum
      #     total.put(:length, total.get(:length) + value, false) 
      #     next total
      #   end

      #   pad = value.get(:length)
      #   len = total.get(:length)
      #   total.def_own_property((pad+len-1).to_s, PropDescriptor.new(:value => value.get_at(pad-1), :writable => true, :enumerable => true, :configurable => true), false)

      #   total
      # end
    end
    rule(:array_literal => simple(:a) ) { ArrayLiteral.new [a] }

    # Object initialiser
    rule(:lcb => simple(:l), :rcb => simple(:r) ) { ObjectLiteral.new }
    rule(:property_name => simple(:name), :assignment_expr => simple(:value) ) do
      OpenStruct.new :name => name.to_s, :expr => value
      #JSPropIdentifier.new(name, PropDescriptor.new(:value => value, :writable => true, :enumerable => true, :configurable => true))
    end

    rule(:property_name => simple(:name), :get_body => simple(:get) ) do
      OpenStruct.new :name => name.to_s, :get => get
    end

    rule(:property_name => simple(:name), :param_list => simple(:param), :set_body => simple(:set)) do
      OpenStruct.new :name => name.to_s, :param => [param.to_s], :set => set
    end
    
    rule(:property_list => simple(:plist) ) do
      ObjectLiteral.new [plist]
      # prop_list = plist
      # JSObject.new do
      #   def_own_property(prop_list.name, prop_list.desc, false)
      # end
    end
    
    rule(:property_list => sequence(:plist) ) do
      ObjectLiteral.new plist
      # prop_list = plist
      # JSObject.new do
      #   prop_list.each { |i| add_property i }
      # end
    end

    rule(:numeric_property_name => simple(:num)) do
      num.to_s
    end

    rule(:obj_literal => simple(:obj)) { obj }

    # left hand side expr
    #

    # subscription
    rule(:subscription => simple(:s)) { s }
    rule(:field_name => simple(:f) ) { f.to_s }
    rule(:member_expr => sequence(:mlist) ) do
      PropertyAccessor.new mlist
      # mlist.inject do |acc, subscription|
      #   base = acc.get_value


      #   property_name = subscription.get_value.to_sym

      #   JSBaseObject.check_coercible(base)

      #   # miss strict logic
      #   JSReference.new(base, property_name)
      # end
    end

    rule(:member_expr => simple(:subject) ) { subject }


    # new operator
    rule(:new_expr => simple(:new_expr)) do
      NewOp.new :constructor => new_expr
    end

    rule(:new_expr => simple(:constructor), :argu => simple(:argu)) do
      NewOp.new :constructor => constructor, :argu => argu
    end

    # function call
    rule(:funccall_ref => simple(:ref), :funccall_arglist => simple(:arg) ) do
      FuncCall.new :member_expr => ref, :argu => [arg]
    end

    rule(:call_expr => simple(:call) ) { call }

    rule(:call_expr => sequence(:call) ) do
      FuncCall.new :member_expr => call.first, :argu => call[1..-1]
    end

    rule(:argu_list => simple(:argu) ) do
      JSList.new [argu]
    end

    rule(:argu_list => sequence(:argu) ) do
      JSList.new argu
    end

    rule(:empty_parenthesis => simple(:empty) ) do
      JSList.empty
    end

    rule(:argument => simple(:argu) ) do
      argu
    end

    # postfix expr
    rule(:lh_side_expr => simple(:lh), :postfix_op => simple(:op) ) do
      if op.nil?
        lh
      else
        PostfixExpr.new :lvalue => lh, :op => op
      end
    end

    # unary expr
    rule(:unary_op => simple(:op), :operant => simple(:operant) ) do
      UnaryExpr.new :op => op, :operant => operant
    end
    rule(:unary_expr => simple(:expr) ) { expr }


    # binary expr
    rule(:binary_expr => sequence(:expr) ) do
      BinaryExpr.new :expr => expr
    end

    rule(:binary_expr => simple(:expr) ) { expr }

    rule(:op => simple(:op), :operant => simple(:operant) ) do
      BinaryOp.new :op => op, :right_operant => operant
    end
    rule(:op => simple(:op), :operant => sequence(:operant) ) do
      BinaryOp.new :op => op, :right_operant => BinaryExpr.new(:expr => operant)
    end

    # ternary expr
    rule(:binary_expr => simple(:prediction), :first => simple(:first), :second => simple(:second) ) do
      TernaryExpr.new :prediction => prediction, :first => first, :second => second
    end
    
    # assignment expr
    rule(:lval => simple(:lval), :assign => simple(:assign), :rval => simple(:rval) ) do
      AssignExpr.new :lval => lval, :assign => assign, :rval => rval
    end
    
    # expr
    rule(:expr => simple(:expr) ) { expr }
    
    # rule(:expr => sequence(:exprs) ) do
    #   Expr.new :expr_list => exprs
    # end

    # function expr
    rule(:formal_parameter => simple(:param) ) { param.to_s }
    rule(:func_expr => simple(:func), :func_name => simple(:name), :param_list => simple(:param), :func_body => simple(:body)) do
      FuncExpr.new :name => name.to_s, :param => [param], :body => body
    end
    rule(:func_expr => simple(:func), :func_name => simple(:name), :param_list => sequence(:param), :func_body => simple(:body)) do
      FuncExpr.new :name => name.to_s, :param => param, :body => body
    end

    # block statement
    rule(:stat_list => simple(:statement) ) { BlockStat.new :stats => [statement] }
    rule(:stat_list => sequence(:stat_list) ) do
      BlockStat.new :stats => stat_list
    end

    # variable statement
    rule(:id => simple(:id), :initialiser => simple(:initialiser) ) do
      VariableStat.new :id => id.to_s, :initialiser => initialiser
    end

    rule(:assignment_expr => simple(:expr) ) do
      expr
    end

    # if statement
    rule(:condition => simple(:condition), :then => simple(:positive), :else => simple(:negitive) ) do
      IfStat.new :if => condition, :then => positive, :else => negitive
    end

    rule(:var_decl_list => simple(:var) ) { var }

    rule(:var_decl_list => sequence(:var_list) ) do
      var_list.inject { |acc, v| acc.append v }
    end

    # do while statement
    rule(:do_stat => simple(:statement), :condition => simple(:condition) ) do
      DoWhileStat.new :statement => statement, :condition => condition
    end
    
    # while statement
    rule(:condition => simple(:condition), :while_stat => simple(:statement) ) do
      WhileStat.new :statement => statement, :condition => condition
    end

    # for statement
    rule(:for_init => simple(:init), :for_condition => simple(:condition), :for_iter => simple(:iter), :for_stat => simple(:statement) ) do
      ForStat.new :init => init, :condition => condition, :iter => iter, :statement => statement
    end

    # continue statement
    rule(:continue => simple(:continute) ) do
      ContinueStat.new
    end

    rule(:continue => simple(:continute), :continue_id => simple(:id) ) do
      ContinueStat.new :id => id
    end
    # todo, no need for empty statement right now

    # break statement
    rule(:break => simple(:break) ) { BreakStat.new }
    rule(:break => simple(:break), :id => simple(:id) ) do
      BreakStat.new :id => id
    end
    
    # return statement
    rule(:return => simple(:return) ) { ReturnStat.new }
    rule(:return => simple(:return), :value => simple(:value) ) do
      ReturnStat.new :value => value
    end

    # with statement
    rule(:with => simple(:with), :expr => simple(:expr), :stat => simple(:stat) ) do
      WithStat.new :expr => expr, :stat => stat
    end

    # switch statement
    rule(:default => simple(:default), :stat_list => simple(:stat_list) ) do
      CaseClause.new :default => default, :stat_list => stat_list;
    end

    rule(:default => simple(:default), :stat_list => sequence(:stat_list) ) do
      CaseClause.new :default => default, :stat_list => stat_list;
    end

    rule(:case => simple(:case), :expr => simple(:expr), :stat_list => simple(:stat_list) ) do
      CaseClause.new :expr => expr, :stat_list => stat_list;
    end

    rule(:case => simple(:case), :expr => simple(:expr), :stat_list => sequence(:stat_list) ) do
      CaseClause.new :expr => expr, :stat_list => stat_list;
    end

    rule(:switch => simple(:switch), :expr => simple(:expr), :case_block => simple(:case_block) ) do
      SwitchStat.new :expr => expr, case_block => case_block
    end
    
    rule(:case_clauses_before => simple(:first), :default_clauses => simple(:default), :case_clauses_after => simple(:second) ) do
      CaseBlock.new :first => first, :default => default, :second => second
    end

    rule(:case_clauses_before => sequence(:first), :default_clauses => simple(:default), :case_clauses_after => simple(:second) ) do
      CaseBlock.new :first => first, :default => default, :second => second
    end

    rule(:case_clauses_before => simple(:first), :default_clauses => simple(:default), :case_clauses_after => sequence(:second) ) do
      CaseBlock.new :first => first, :default => default, :second => second
    end

    rule(:case_clauses_before => sequence(:first), :default_clauses => simple(:default), :case_clauses_after => sequence(:second) ) do
      CaseBlock.new :first => first, :default => default, :second => second
    end

    rule(:case_clauses_before => simple(:first) ) do
      CaseBlock.new :first => first
    end

    rule(:case_clauses_before => sequence(:first) ) do
      CaseBlock.new :first => first
    end

    # label statement
    rule(:id => simple(:id), :stat => simple(:stat) ) do
      LabelStat.new :id => id, :stat => stat
    end
    
    # throw statement
    rule(:throw => simple(:throw), :expr => simple(:expr) ) do
      ThrowStat.new :expr => expr
    end

    # try statement
    rule(:try => simple(:try), :block => simple(:block), :catch => simple(:catch_block), :finally => simple(:finally) ) do
      TryStat.new :block => block, :catch_block => catch_block, :finally => finally
    end

    rule(:try => simple(:try), :block => simple(:block), :finally => simple(:finally) ) do
      TryStat.new :block => block, :finally => finally
    end
    
    # debugger statement
    rule(:debugger => simple(:debugger) ) { DebugStat.new }

    # expr statement
    rule(:expr_in_stat => simple(:expr) ) { Expr.new :expr => [expr] }
    rule(:expr_in_stat => sequence(:expr) ) { Expr.new :expr => expr }

    rule(:expr_stat => simple(:expr) ) { ExprStat.new :expr => expr }
    
    # function declaration
    rule(:func_decal => simple(:func)) do
      func
    end

    rule(:func_decal => simple(:func), :func_name => simple(:name), :param_list => simple(:param), :func_body => simple(:body)) do
      FuncDeclStat.new :func_name => name, :param_list => param, :body => body
    end
    
    rule(:source => simple(:source)) do
      Sources.new [source]
    end

    rule(:source => sequence(:sources)) do
      Sources.new sources
    end

    rule(:statement => simple(:state)) do
      state
    end
  end
end
 
