# -*- coding: utf-8 -*-
require 'parslet'
require 'lexical'
require 'expression'
require 'util'

module Moonr
  module Statement
    include Parslet
    include Lexical
    include Expression

    #end of statement
    #EOS
    #  S? ";"
    #  SnoLB? LineTerminatorSequence
    #  SnoLB? &("}")
    #  S? EOF

    #end of statement in a "no linebreak here" context
    #EOSnoLB will consume a linebreak, but it won't extend to the next line
    #EOSnoLB
    #  SnoLB? ";"
    #  SnoLB? LineTerminatorSequence
    #  SnoLB? &("}")
    #  SnoLB? EOF

    rule(:se) { 
      nl_ws >> ( line_term_seq | str('}').present? ) |
      ws >> ( str(';') | eof )
    }

    rule(:nl_se) {
      nl_ws >> ( str(';') | line_term_seq | str('}').present? | eof )
    }

    #Statement : 
    #  Block
    #  VariableStatement 
    #  EmptyStatement 
    #  ExpressionStatement 
    #  IfStatement 
    #  IterationStatement 
    #  ContinueStatement 
    #  BreakStatement 
    #  ReturnStatement 
    #  WithStatement 
    #  LabelledStatement 
    #  SwitchStatement 
    #  ThrowStatement 
    #  TryStatement 
    #  DebuggerStatement
    rule(:statement) {
      block |
      variable_state |
      empty_state |
      expr_state |
      if_state |
      iteration_state |
      continue_state |
      break_state |
      return_state |
      with_state |
      labelled_state.as(:label) |
      switch_state |
      throw_state |
      try_state |
      debugger_state
    }

    #Block :
    #  { StatementList? }
    rule(:block) {
      str('{') + state_list.maybe.as(:statements) + str('}')
    }


    #StatementList : 
    #  Statement
    #  StatementList Statement 
    rule(:state_list) {
      statement >> ( ws >> statement ).repeat
    }

    #VariableStatement :
    #  var VariableDeclarationList ;
    rule(:variable_state) {
      ( str('var') | str('const') ) + variable_declaration_list.as(:var_list) >> se.as(:se) 
    }


    #VariableDeclarationList : 
    #  VariableDeclaration
    #  VariableDeclarationList , VariableDeclaration
    rule(:variable_declaration_list) {
      variable_declaration >> ( ws >>  str(',') + variable_declaration ).repeat
    }

    #VariableDeclarationListNoIn : 
    #  VariableDeclarationNoIn
    #  VariableDeclarationListNoIn , VariableDeclarationNoIn 
    rule(:variable_declaration_list_noin) {
      variable_declaration_noin >> ( ws >> str(',') + variable_declaration_noin ).repeat
    }

    #VariableDeclaration :
    #  Identifier Initialiser?
    rule(:variable_declaration) {
      identifier >> ( ws >> initialiser).maybe.as(:initialiser) 
    }

    #VariableDeclarationNoIn : 
    #  Identifier InitialiserNoInopt
    rule(:variable_declaration_noin) {
      identifier >> ( ws >> initialiser_noin).maybe 
    }


    #Initialiser :
    #  = AssignmentExpression
    rule(:initialiser) {
      str('=') + assignment_expr.as(:assignment_expr) 
    }


    #InitialiserNoIn :
    #  = AssignmentExpressionNoIn
    rule(:initialiser_noin) {
      str('=') + assignment_expr_noin 
    }

    #EmptyStatement : 
    #  ;
    rule(:empty_state) {
      str(';')
    }

    #ExpressionStatement :
    #  [lookahead 􏰀no {{, function}] Expression ;
    rule(:expr_state) {
      ( str('{') | str('function') ).absent? >> expr >> se
    }

    #IfStatement :
    #  if ( Expression ) Statement else Statement 
    #  if ( Expression ) Statement
    rule(:if_state) {
      str('if') + str('(') + expr + str(')') + statement + ( str('else') + statement ).maybe
    }

    #IterationStatement :
    #  do Statement while ( Expression ) ;
    #  while ( Expression ) Statement
    #  for ( ExpressionNoInopt ; Expressionopt ; Expressionopt ) Statement 
    #  for ( var VariableDeclarationListNoIn ; Expressionopt ; Expressionopt ) Statement 
    #  for ( LeftHandSideExpression in Expression ) Statement 
    #  for ( var VariableDeclarationNoIn in Expression ) Statement
    rule(:iteration_state) {
      str('do') + statement + str('while') + str('(') + expr + str(')') |
      str('while') + str('(') + expr + str(')') + statement |
      str('for') + str('(') + ( for_clause_a | for_clause_b | for_clause_c ) + str(')') + statement 
    }

    #  for ( ExpressionNoInopt ; Expressionopt ; Expressionopt ) Statement 
    rule(:for_clause_a) {
      expr_noin.maybe + str(';') + expr.maybe + str(';') + expr.maybe 
    }
    rule(:for_clause_b) {
      lh_side_expr + str('in') + expr 
    }
    rule(:for_clause_c) {
      str('var') + ( variable_declaration_list_noin + str(';') + expr.maybe + str(';') + expr.maybe |
                     variable_declaration_noin + str('in') + expr
                     )
    }

    #ContinueStatement : 
    #  continue ;
    #  continue [no LineTerminator here] Identifier ;
    rule(:continue_state) {
      str('continue') >> nl_ws >> ( identifier >> se | nl_se )
    }

    
    #BreakStatement : 
    #  break ;
    #  break [no LineTerminator here] Identifier ;
    rule(:break_state) {
      str('break') >> nl_ws >> ( identifier >> se | nl_se )
    }
    
    #ReturnStatement : 
    #  return ;
    #  return [no LineTerminator here] Expression ;
    rule(:return_state) {
      str('return') >>  nl_ws >>( expr >> se | nl_se )
    }

    #WithStatement :
    #  with ( Expression ) Statement 
    rule(:with_state) {
      str('with') + str('(') + expr + str(')') + statement
    }

    #SwitchStatement :
    #  switch ( Expression ) CaseBlock
    rule(:switch_state) {
      str('switch') + str('(') + expr + str(')') + case_block 
    }

    #CaseBlock :
    #  { CaseClausesopt }
    #  { CaseClausesopt DefaultClause CaseClausesopt }
    rule(:case_block) {
      str('{') + case_clauses.maybe + ( default_clause + case_clauses.maybe ).maybe + str('}')
    }
    

    #CaseClauses : 
    #  CaseClause
    #  CaseClauses CaseClause
    rule(:case_clauses) {
      case_clause >> ( ws >> case_clause ).repeat
    }

    #CaseClause :
    #  case Expression : StatementListopt
    rule(:case_clause) {
      str('case') + expr + str(':') + state_list.maybe
    }

    #DefaultClause :
    #  default : StatementListopt
    rule(:default_clause) {
      str('default') + str(':') + state_list.maybe 
    }


    #LabelledStatement : 
    #  Identifier : Statement
    rule(:labelled_state) {
      identifier + str(':') + statement
    }


    #ThrowStatement :
    #  throw [no LineTerminator here] Expression ;
    rule(:throw_state) {
      str('throw') >> nl_ws >> ( expr >> se | nl_se )
    }

    #TryStatement :
    #  try Block Catch
    #  try Block Finally
    #  try Block Catch Finally
    rule(:try_state) {
      str('try') + block + ( finally |
                             catch_state >> ( ws >> finally ).maybe
                             )
    }

    #Catch :
    #  catch ( Identifier ) Block
    rule(:catch_state) {
      str('catch') + str('(') + identifier + str(')') + block
    }
    
    #Finally :
    #  finally Block
    rule(:finally) {
      str('finally') + block
    }
    
    #DebuggerStatement : 
    #  debugger ;
    rule(:debugger_state) {
     str('debugger') >> se
    }


    #FunctionDeclaration :
    #  function Identifier ( FormalParameterListopt ){ FunctionBody } 
    rule(:function_declaration) {
      str('function') + identifier + str('(') + formal_paramter_list.maybe + str(')') + str('{') + function_body + str('}')
    }
    
    #FunctionExpression :
    #  function Identifieropt ( FormalParameterListopt ){ FunctionBody }
    rule(:function_expr) {
      str('function') + identifier.maybe + str('(') + formal_paramter_list.maybe + str(')') + str('{') + function_body + str('}')
    }

    #FormalParameterList : 
    #  Identifier
    #  FormalParameterList , Identifier 
    rule(:formal_paramter_list) {
      identifier >> (ws >> str(',') + identifier ).repeat 
    }


    #FunctionBody :
    #  SourceElementsopt 
    rule(:function_body) {
      source_elements.maybe
    }
    
    #Program :
    #  SourceElementsopt
    rule(:program) {
      ws >> source_elements.maybe >> ws
    }

    #SourceElements : 
    #  SourceElement
    #   SourceElements SourceElement
    rule(:source_elements) {
      source_element >> ( ws >> source_element).repeat
    }

    #SourceElement : 
    #  Statement
    #  FunctionDeclaration
    rule(:source_element) {
      function_declaration |
      statement
      
    }

  end
end
