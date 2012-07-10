# -*- coding: utf-8 -*-
module Moonr
  module Statement
    include Parslet
    include Lexical
    include Expression


    # wrap expr for ease usage in statement
    rule(:expr_in_stat) { expr.as(:expr_in_stat) }

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
      expr_state.as(:expr_stat) |
      if_state |
      iteration_state |
      continue_state |
      break_state |
      return_state |
      with_state |
      labelled_state |
      switch_state |
      throw_state |
      try_state |
      debugger_state
    }

    #Block :
    #  { StatementList? }
    rule(:block) {
      str('{') + stat_list.maybe.as(:stat_list) + str('}')
    }


    #StatementList : 
    #  Statement
    #  StatementList Statement 
    rule(:stat_list) {
      statement >> ( ws >> statement ).repeat
    }

    #VariableStatement :
    #  var VariableDeclarationList ;
    rule(:variable_state) {
      # const ??
      ( str('var') | str('const') ) + variable_declaration_list.as(:var_decl_list) >> se
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
      identifier.as(:id) >> ( ws >> initialiser).maybe.as(:initialiser) 
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
      ( str('{') | str('function') ).absent? >> expr_in_stat.as(:expr) >> se
    }

    #IfStatement :
    #  if ( Expression ) Statement else Statement 
    #  if ( Expression ) Statement
    rule(:if_state) {
      str('if') + str('(') + expr_in_stat.as(:condition) + str(')') + statement.as(:then) + ( str('else') + statement.as(:else) ).maybe
    }

    #IterationStatement :
    #  do Statement while ( Expression ) ;
    #  while ( Expression ) Statement
    #  for ( ExpressionNoInopt ; Expressionopt ; Expressionopt ) Statement 
    #  for ( var VariableDeclarationListNoIn ; Expressionopt ; Expressionopt ) Statement 
    #  for ( LeftHandSideExpression in Expression ) Statement 
    #  for ( var VariableDeclarationNoIn in Expression ) Statement
    rule(:iteration_state) {
      str('do') + statement.as(:do_stat) + str('while') + str('(') + expr_in_stat.as(:condition) + str(')') |
      str('while') + str('(') + expr_in_stat.as(:condition) + str(')') + statement.as(:while_stat) |
      str('for') + str('(') + ( for_clause_a | for_clause_b | for_clause_c ) + str(')') + statement.as(:for_stat) 
    }

    #  for ( ExpressionNoInopt ; Expressionopt ; Expressionopt ) Statement 
    rule(:for_clause_a) {
      expr_noin.maybe.as(:for_init) + str(';') + expr_in_stat.maybe.as(:for_condition) + str(';') + expr_in_stat.maybe.as(:for_iter) 
    }
    rule(:for_clause_b) {
      lh_side_expr + str('in') + expr 
    }
    rule(:for_clause_c) {
      str('var') + ( variable_declaration_list_noin + str(';') + expr_in_stat.maybe + str(';') + expr_in_stat.maybe |
                     variable_declaration_noin + str('in') + expr
                     )
    }

    #ContinueStatement : 
    #  continue ;
    #  continue [no LineTerminator here] Identifier ;
    rule(:continue_state) {
      str('continue').as(:continue) >> nl_ws >> ( identifier.as(:continue_id) >> se | nl_se )
    }

    
    #BreakStatement : 
    #  break ;
    #  break [no LineTerminator here] Identifier ;
    rule(:break_state) {
      str('break').as(:break) >> nl_ws >> ( identifier.as(:id) >> se | nl_se )
    }
    
    #ReturnStatement : 
    #  return ;
    #  return [no LineTerminator here] Expression ;
    rule(:return_state) {
      str('return').as(:return) >>  nl_ws >>( expr_in_stat.as(:value) >> se | nl_se )
    }

    #WithStatement :
    #  with ( Expression ) Statement 
    rule(:with_state) {
      str('with').as(:with) + str('(') + expr_in_stat.as(:expr) + str(')') + statement.as(:stat)
    }

    #SwitchStatement :
    #  switch ( Expression ) CaseBlock
    rule(:switch_state) {
      str('switch').as(:switch) + str('(') + expr_in_stat.as(:expr) + str(')') + case_block.as(:case_block)
    }

    #CaseBlock :
    #  { CaseClausesopt }
    #  { CaseClausesopt DefaultClause CaseClausesopt }
    rule(:case_block) {
      str('{') + case_clauses.maybe.as(:case_clauses_before) + ( default_clause.as(:default_clauses) + case_clauses.maybe.as(:case_clauses_after) ).maybe + str('}')
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
      str('case').as(:case) + expr_in_stat.as(:expr) + str(':') + stat_list.maybe.as(:stat_list)
    }

    #DefaultClause :
    #  default : StatementListopt
    rule(:default_clause) {
      str('default').as(:default) + str(':') + stat_list.maybe.as(:stat_list) 
    }


    #LabelledStatement : 
    #  Identifier : Statement
    rule(:labelled_state) {
      identifier.as(:id) + str(':') + statement.as(:stat)
    }


    #ThrowStatement :
    #  throw [no LineTerminator here] Expression ;
    rule(:throw_state) {
      str('throw').as(:throw) >> nl_ws >> ( expr_in_stat.as(:expr) >> se | nl_se )
    }

    #TryStatement :
    #  try Block Catch
    #  try Block Finally
    #  try Block Catch Finally
    rule(:try_state) {
      str('try').as(:try) + block.as(:block) + ( finally.as(:finally) |
                             catch_state.as(:catch) >> ( ws >> finally ).maybe.as(:finally)
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
     str('debugger').as(:debugger) >> se
    }


    #FunctionDeclaration :
    #  function Identifier ( FormalParameterListopt ){ FunctionBody } 
    rule(:function_declaration) {
      str('function').as(:func_decal) + identifier.as(:func_name) + str('(') + formal_parameter_list.maybe.as(:param_list) + str(')') + str('{') + function_body.as(:func_body) + str('}')
    }
    
    #FunctionExpression :
    #  function Identifieropt ( FormalParameterListopt ){ FunctionBody }
    rule(:function_expr) {
      str('function').as(:func_expr) + identifier.maybe.as(:func_name) + str('(') + formal_parameter_list.maybe.as(:param_list) + str(')') + str('{') + function_body.as(:func_body) + str('}')
    }

    #FormalParameterList : 
    #  Identifier
    #  FormalParameterList , Identifier 
    rule(:formal_parameter_list) {
      identifier.as(:formal_parameter) >> (ws >> str(',') + identifier.as(:formal_parameter) ).repeat 
    }


    #FunctionBody :
    #  SourceElementsopt 
    rule(:function_body) {
      source_elements.maybe.as(:source)
    }
    
p    #Program :
    #  SourceElementsopt
    rule(:program) {
      ws >> source_elements.maybe.as(:source) >> ws
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
      function_declaration.as(:func_decal) |
      statement.as(:statement)
      
    }

  end
end
