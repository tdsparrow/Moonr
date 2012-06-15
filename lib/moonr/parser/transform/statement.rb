module Moonr
  class Stms < Parslet::Transform
    rule(:primary_expr => simple(:prime)) { prime }

    rule(:identifier => simple(:id) )do
      IdExpr.new :id => id
    end

    # Array initialiser
    rule(:elision => simple(:e) ) { e.to_s.count(',') }
    rule(:elisions => simple(:e) ) { e.nil? ? 0:e }

    # [ , , , ]
    rule(:al => simple(:al), :elisions => simple(:e), :ar => simple(:ar) ) do
      len = e.nil? ? 0:e
      JSArray.new(len)
    end
    
    rule(:elisions => simple(:e), :assignment => simple(:a) ) do
      ind = e.nil? ? 0 : e
      obj = JSArray.new(ind) 
      obj.def_own_property(ind.to_s, PropDescriptor.new(:value => a, :writable => true, :enumerable => true, :configurable => true), false )
      obj
    end

    rule(:array_literal => sequence(:a) ) do
      ret = a.inject do |total, value|
        if value.is_a? Fixnum
          total.put(:length, total.get(:length) + value, false) 
          next total
        end

        pad = value.get(:length)
        len = total.get(:length)
        total.def_own_property((pad+len-1).to_s, PropDescriptor.new(:value => value.get_at(pad-1), :writable => true, :enumerable => true, :configurable => true), false)

        total
      end
    end
    rule(:array_literal => simple(:a) ) { a }

    # Object initialiser
    rule(:lcb => simple(:l), :rcb => simple(:r) ) { JSObject.new }
    rule(:property_name => simple(:name), :assignment_expr => simple(:value) ) do
      JSPropIdentifier.new(name, PropDescriptor.new(:value => value, :writable => true, :enumerable => true, :configurable => true))
    end

    rule(:property_name => simple(:name), :get_body => simple(:get) ) do
      getter = JSFunction.new nil, get
      JSPropIdentifier.new(name, PropDescriptor.new(:get => getter, :enumerable => true, :configurable => true))
    end

    rule(:property_name => simple(:name), :param_list => simple(:param), :set_body => simple(:set)) do
      setter = JSFunction.new nil, param, set
      JSPropIdentifier.new(name, PropDescriptor.new(:set => setter, :enumerable => true, :configurable => true))
    end
    
    rule(:property_list => simple(:plist) ) do
      prop_list = plist
      JSObject.new do
        def_own_property(prop_list.name, prop_list.desc, false)
      end
    end
    
    rule(:property_list => sequence(:plist) ) do
      prop_list = plist
      JSObject.new do
        prop_list.each { |i| add_property i }
      end
    end

    rule(:numeric_property_name => simple(:num)) do
      num.to_s
    end

    rule(:obj_literal => simple(:obj)) { obj }

    # left hand side expr
    #

    # subscription
    rule(:subscription => simple(:s)) { s.to_s }
    rule(:member_expr => sequence(:mlist) ) do
      mlist.inject do |acc, subscription|
        base = acc.get_value


        property_name = subscription.get_value.to_sym

        JSBaseObject.check_coercible(base)

        # miss strict logic
        JSReference.new(base, property_name)
      end
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
      FuncCall.new :ref => ref, :arg_list => arg
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
    
    rule(:expr => sequence(:exprs) ) do
      Expr.new :expr_list => exprs
    end

    # function declaration
    rule(:func_decal => simple(:func)) do
      func
    end

    rule(:func_name => simple(:name), :param_list => simple(:param), :func_body => simple(:body)) do
      FuncDef.new :name => name, :param => param, :body => body
    end

    # block statement
    rule(:stat_list => simple(:statement) ) { BlockStat.new :stats => [statement] }
    rule(:stat_list => sequence(:stat_list) ) do
      BlockStat.new :stats => stat_list
    end

    # variable statement
    rule(:id => simple(:id), :initialiser => simple(:initialiser) ) do
      VariableStat.new :id => id, :initialiser => initialiser
    end

    # if statement
    rule(:condition => simple(:condition), :then => simple(:positive), :else => simple(:negitive) ) do
      IfStat.new :if => condition, :then => positive, :else => negitive
    end

    rule(:var_decl_list => simple(:var) ) { var }

    rule(:var_decl_list => sequence(:var_list) ) do
      var_list.inject { |acc, v| acc.append v }
    end
    
    # todo, no need for empty statement right now

    # expr statement
    rule(:expr_stat => simple(:expr) ) { ExprStat.new :expr => expr }


    rule(:sources => simple(:source)) do
      JSSources.new [source]
    end

    rule(:sources => sequence(:sources)) do
      JSSources.new sources
    end

    rule(:statement => simple(:state)) do
      state
    end
  end
end
 
