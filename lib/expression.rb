# -*- coding: utf-8 -*-
require 'parslet'
require 'lexical'
require 'util'

module Moonr
  module Expression
    include Parslet
    include Lexical
    
    # Primary Expression
    # Origin production:
    # PrimaryExpression :
    #     this
    #     Identifier
    #     Literal
    #     ArrayLiteral
    #     ObjectLiteral
    #     ( Expression )
    rule(:primary_expr) do
      str('this') |
      identifier |
      literal |
      array_literal.as(:array_literal) |
      object_literal |
      str('(') + expr + str(')') 
    end
    
    #ArrayLiteral : 
    #   [ Elision(opt) ]
    #   [ ElementList  ]
    #   [ ElementList , Elision(opt) ]
    rule(:array_literal) { 
      str('[')  + elision? + str(']') |
      str('[') + element_list + ( str(',') + elision? ).maybe + str(']')
    }


    #ElementList :
    #  Elision(opt) AssignmentExpression
    #  ElementList , Elision(opt) AssignmentExpression
    rule(:element_list) {
      elision? + assignment_expr.as(:assignment) >> ( ws >> str(',') + elision? + assignment_expr.as(:assignment) ).repeat
    }
    
    #Elision : 
    #  ,
    #  Elision ,
    rule(:elision) { str(',') >>( ws >> str(',') ).repeat }
    rule(:elision?) { elision.as(:elision).maybe.as(:elisions) }

    #ObjectLiteral : 
    #  { }
    #  { PropertyNameAndValueList }
    #  { PropertyNameAndValueList , }
    rule(:object_literal) {
      str('{').as(:lcb) + str('}').as(:rcb) |
      str('{') + property_name_and_val_list.as(:property_list) + str(',').maybe + str('}') 
    }
  
    #PropertyNameAndValueList : 
    #  PropertyAssignment
    #  PropertyNameAndValueList , PropertyAssignment
    rule(:property_name_and_val_list) { 
       property_assignment >>  ( ws >>  str(',') + property_assignment ).repeat
    }
    
    #PropertyAssignment :
    #  PropertyName : AssignmentExpression
    #  get PropertyName ( ) { FunctionBody } 
    #  set PropertyName ( PropertySetParameterList ) { FunctionBody }
    rule(:property_assignment) {
      str('get') + property_name + str('(') + str(')') + str('{') + function_body + str('}') |
      str('set') + property_name + str('(') + property_set_param_list + str(')') + str('{') + function_body + str('}') |
      property_name.as(:property_name) + str(':') + assignment_expr.as(:assignment_expr)

    }

    #PropertyName : 
    #  IdentifierName
    #  StringLiteral 
    #  NumericLiteral
    rule(:property_name) {
      identifier_name |
      string_literal |
      numeric_literal
    }

    #PropertySetParameterList : 
    #  Identifier
    rule(:property_set_param_list) { identifier }

    #MemberExpression : 
    #  PrimaryExpression
    #  FunctionExpression 
    #  MemberExpression [ Expression ]
    #  MemberExpression . IdentifierName 
    #  new MemberExpression Arguments
    rule(:member_expr) {
      ( primary_expr | function_expr | member_expr_b ) >> ( ws >> subscription_expr | field_expr ).repeat
    }
    rule(:member_expr_b) {
      str('new') + member_expr + arguments
    }
    
    #NewExpression : 
    #  MemberExpression
    #  new NewExpression
    rule(:new_expr) {
      member_expr |
      str('new') + new_expr 
    }

    #CallExpression : 
    #  MemberExpression Arguments 
    #  CallExpression Arguments 
    #  CallExpression [ Expression ] 
    #  CallExpression . IdentifierName
    rule(:call_expr) {
      member_expr + arguments >> ( ws >> ( arguments | subscription_expr | field_expr ) ).repeat
    }
    # [ Expression ]
    rule(:subscription_expr) {
      str('[') + expr + str(']')
    }
    # . IdentifierName
    rule(:field_expr) {
      str('.') + identifier_name 
    }

    #Arguments : 
    #  ()
    #  ( ArgumentList )
    rule(:arguments) {
      str('(') + argument_list + str(')') |
      str('(') + str(')')

    }

    #ArgumentList : 
    #  AssignmentExpression
    # ArgumentList , AssignmentExpression
    rule(:argument_list) {
      assignment_expr >> ( ws >> str(',') + assignment_expr.as(:argument) ).repeat 
    }
    
    #LeftHandSideExpression : 
    #  NewExpression 
    #  CallExpression
    # 
    #  new_expr share same member_expr prefix with call_expr
    rule(:lh_side_expr) {
      call_expr |
      new_expr
    }

    #PostfixExpression : 
    #  LeftHandSideExpression
    #  LeftHandSideExpression [no LineTerminator here] ++ 
    #  LeftHandSideExpression [no LineTerminator here] --
    rule(:postfix_expr) {
      # lh_side_expr >> nl_ws >> str('++') |
      # lh_side_expr >> nl_ws >> str('--') |
      # lh_side_expr.as(:lh_side_expr)
      lh_side_expr >> ( nl_ws >> ( str('++') | str('--') ) ).maybe
    }

    #UnaryExpression : 
    #  PostfixExpression
    #  delete UnaryExpression 
    #  void UnaryExpression 
    #  typeof UnaryExpression
    #  ++ UnaryExpression
    #  -- UnaryExpression 
    #  + UnaryExpression 
    #  - UnaryExpression 
    #  ~ UnaryExpression 
    #  ! UnaryExpression
    rule(:unary_expr) {
      postfix_expr |
      str('delete') + unary_expr |
      str('void') + unary_expr |
      str('typeof') + unary_expr |
      str('++') + unary_expr |
      str('--') + unary_expr |
      str('+') + unary_expr |
      str('-').as(:minus) + unary_expr |
      str('~') + unary_expr |
      str('!') + unary_expr
    }

    #MultiplicativeExpression : 
    #  UnaryExpression
    #  MultiplicativeExpression * UnaryExpression 
    #  MultiplicativeExpression / UnaryExpression 
    #  MultiplicativeExpression % UnaryExpression
    rule(:multiplicative_expr) {
      unary_expr >> ( ws >> ( (str('*') + unary_expr) | (str('/') + unary_expr) | (str('%') + unary_expr) ) ).repeat
    }

    #AdditiveExpression : 
    #  MultiplicativeExpression
    #  AdditiveExpression + MultiplicativeExpression 
    #  AdditiveExpression - MultiplicativeExpression
    rule(:additive_expr) {
      multiplicative_expr >> ( ws >>( (str('+') + multiplicative_expr) | (str('-') + multiplicative_expr) ) ).repeat
    }
    
    #ShiftExpression : 
    #  AdditiveExpression
    #  ShiftExpression << AdditiveExpression 
    #  ShiftExpression >> AdditiveExpression 
    #  ShiftExpression >>> AdditiveExpression
    rule(:shift_expr) {
      additive_expr >> ( ws >> ( postfix %w{ >> << >>> }, additive_expr ) ).repeat
    }

    #RelationalExpression : 
    #  ShiftExpression
    #  RelationalExpression < ShiftExpression 
    #  RelationalExpression > ShiftExpression 
    #  RelationalExpression <= ShiftExpression 
    #  RelationalExpression >= ShiftExpression 
    #  RelationalExpression instanceof ShiftExpression 
    #  RelationalExpression in ShiftExpression
    rule(:relational_expr) {
      shift_expr >> ( ws >> ( postfix %w{ < > <= >= instanceof in }, shift_expr ) ).repeat
    }

    #RelationalExpressionNoIn : 
    #  ShiftExpression
    #  RelationalExpressionNoIn < ShiftExpression 
    #  RelationalExpressionNoIn > ShiftExpression 
    #  RelationalExpressionNoIn <= ShiftExpression 
    #  RelationalExpressionNoIn >= ShiftExpression 
    #  RelationalExpressionNoIn instanceof ShiftExpression
    rule(:relational_expr_noin) {
      shift_expr >> ( ws >> ( postfix %w{ < > <= >= instanceof }, shift_expr ) ).repeat
    }

    #EqualityExpression : 
    #  RelationalExpression
    #  EqualityExpression == RelationalExpression 
    #  EqualityExpression != RelationalExpression 
    #  EqualityExpression === RelationalExpression 
    #  EqualityExpression !== RelationalExpression
    rule(:equality_expr) {
      relational_expr >> ( ws >> ( postfix %w{ == != === !== }, relational_expr ) ).repeat
    }
    
    #EqualityExpressionNoIn : 
    #  RelationalExpressionNoIn
    #  EqualityExpressionNoIn == RelationalExpressionNoIn 
    #  EqualityExpressionNoIn != RelationalExpressionNoIn 
    #  EqualityExpressionNoIn === RelationalExpressionNoIn 
    #  EqualityExpressionNoIn !== RelationalExpressionNoIn
    rule(:equality_expr_noin) {
      relational_expr_noin >> ( ws >> ( postfix %w{ == != === !== }, relational_expr_noin) ).repeat
    }

    #BitwiseANDExpression : 
    #  EqualityExpression
    #  BitwiseANDExpression & EqualityExpression
    rule(:bitand_expr) {
      equality_expr >> ( ws >> str('&') + equality_expr ).repeat
    }
    
    #BitwiseANDExpressionNoIn : 
    #  EqualityExpressionNoIn
    #  BitwiseANDExpressionNoIn & EqualityExpressionNoIn
    rule(:bitand_expr_noin) {
      equality_expr_noin >> ( ws >> str('&') + equality_expr_noin ).repeat
    }
    
    #BitwiseXORExpression : 
    #  BitwiseANDExpression
    #  BitwiseXORExpression ^ BitwiseANDExpression
    rule(:bitxor_expr) {
      bitand_expr >>  ( ws >> str('^') + bitand_expr ).repeat
    }

    #BitwiseXORExpressionNoIn : 
    #  BitwiseANDExpressionNoIn
    #  BitwiseXORExpressionNoIn ^ BitwiseANDExpressionNoIn
    rule(:bitxor_expr_noin) {
      bitand_expr_noin >> ( ws >> str('^') + bitand_expr_noin ).repeat
    }

    #BitwiseORExpression : 
    #  BitwiseXORExpression
    #  BitwiseORExpression | BitwiseXORExpression
    rule(:bitor_expr) {
      bitxor_expr >> ( ws >> str('|') + bitxor_expr ).repeat
    }
    
    #BitwiseORExpressionNoIn : 
    #  BitwiseXORExpressionNoIn
    #  BitwiseORExpressionNoIn | BitwiseXORExpressionNoIn
    rule(:bitor_expr_noin) {
      bitxor_expr_noin >> ( ws >> str('|') + bitxor_expr_noin ).repeat
    }

    #LogicalANDExpression : 
    #  BitwiseORExpression
    #  LogicalANDExpression && BitwiseORExpression
    rule(:logical_and_expr) {
      bitor_expr >> ( ws >> str('&&') + bitor_expr ).repeat
    }

    #LogicalANDExpressionNoIn : 
    #  BitwiseORExpressionNoIn
    #  LogicalANDExpressionNoIn && BitwiseORExpressionNoIn
    rule(:logical_and_expr_noin) {
      bitor_expr_noin >> ( ws >> str('&&') + bitor_expr_noin ).repeat
    }

    #LogicalORExpression : 
    #  LogicalANDExpression
    #  LogicalORExpression || LogicalANDExpression
    rule(:logical_or_expr) {
      logical_and_expr >> ( ws >> str('||') + logical_and_expr ).repeat
    }
    
    #LogicalORExpressionNoIn : 
    #  LogicalANDExpressionNoIn
    #  LogicalORExpressionNoIn || LogicalANDExpressionNoIn
    rule(:logical_or_expr_noin) {
      logical_and_expr_noin >> ( ws >> str('||') + logical_and_expr_noin ).repeat
    }
    
    #ConditionalExpression : 
    #  LogicalORExpression
    #  LogicalORExpression ? AssignmentExpression : AssignmentExpression
    rule(:cond_expr) {
      logical_or_expr >> ( ws >> str('?') + assignment_expr + str(':') + assignment_expr ).maybe
    }
    
    #ConditionalExpressionNoIn : 
    #  LogicalORExpressionNoIn
    #  LogicalORExpressionNoIn ? AssignmentExpression : AssignmentExpressionNoIn
    rule(:cond_expr_noin) {
      logical_or_expr_noin >> ( ws >> str('?') + assignment_expr + str(':') + assignment_expr_noin ).maybe
    }

    #AssignmentExpression : 
    #  ConditionalExpression
    #  LeftHandSideExpression = AssignmentExpression 
    #  LeftHandSideExpression AssignmentOperator AssignmentExpression
    rule(:assignment_expr) {
      lh_side_expr + ( str('=') + assignment_expr | assignment_operator + assignment_expr ) |
      cond_expr
    }

    #AssignmentExpressionNoIn : 
    #  ConditionalExpressionNoIn
    #  LeftHandSideExpression = AssignmentExpressionNoIn 
    #  LeftHandSideExpression AssignmentOperator AssignmentExpressionNoIn
    rule(:assignment_expr_noin) {
      lh_side_expr + ( str('=') + assignment_expr_noin | assignment_operator + assignment_expr_noin ) |
      cond_expr_noin
    }

    #AssignmentOperator : one of
    #  *= /= %= += -= <<= >>= >>>= &= ^= |=
    rule(:assignment_operator) {
      oneof %w{ *= /= %= += -= <<= >>= >>>= &= ^= |=}
    }

    #Expression : 
    #  AssignmentExpression
    #  Expression , AssignmentExpression
    rule(:expr) {
      assignment_expr >> ( ws >> str(',')  + assignment_expr ).repeat
    }
    
    #ExpressionNoIn : 
    #  AssignmentExpressionNoIn
    #  ExpressionNoIn , AssignmentExpressionNoIn
    rule(:expr_noin) {
      assignment_expr_noin >> ( ws >> str(',') + assignment_expr_noin ).repeat
    }

  end
end
