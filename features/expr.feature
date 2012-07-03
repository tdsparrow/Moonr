@eval
Feature: Moonr eval js expression

  Scenario: Moonr eval this expr
    Given a js literal "this" is provided
    When i parse it using moonr lh_side_expr
    Then i get the ThisBind element
    When i eval it with global execution context
    Then i get a GlobalObject result

  Scenario: Moonr eval identifier expr
    Given a js literal "a" is provided
    When i parse it using moonr lh_side_expr
    Then i get the IdExpr element
    When i eval it with execution context "var a;"
    Then i get a JSReference result 


  Scenario Outline: Moonr eval array initialiser
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the ArrayLiteral element
    When i eval it with execution context "var a=1,b=2,c=2;"
    Then i get a JSArray result
    And i get "<result>" with property "<index>"
    
    Examples:
      | literal       | size | index |    result |
      | [ , , ]       |    2 |     0 | undefined |
      | [ , , ,]      |    3 |     1 | undefined |
      | [ a,b,,,]     |    3 |     0 |         1 |
      | [ a, b, c, ,] |    4 |     1 |         2 |
      | [ a,,  , b ]  |    4 |     3 |         2 |
      | [,]           |    1 |     0 | undefined |
      | [a]           |    1 |     0 |         1 |
      | [    ]        |    0 |     0 | undefined |
      | [ , , , a]    |    4 |     3 |         1 |




  Scenario Outline: Moonr eval object initialiser
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the object with <size> properites

    Examples:
      | literal                      | size |
      | { a: 'x'}                    |    1 |
      | {}                           |    0 |
      | { a: 'x', b: 'y' }           |    2 |
      | { a: 'x', get my_a() { 2;} } |    2 |
      | { a:'x', set my_a(a) { 2;} } |    2 |
      | { 1: 1}                      |    1 |


  Scenario Outline: Moonr eval property accessor
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the reference with <value> of <property>

    Examples:
      | literal               | value | property |
      | {a: 'x', b: 'y'}['a'] | x     | a        |
      | {a: 'x', b: 'y'}.b    | y     | b        |


  Scenario Outline: Moonr eval new operator
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the NewOp element
    When i eval it with global env
    Then i get a new function
    
    Examples:
      | literal                     | 
      | new function() { return 1 } | 
      | new foo(whatever)           | 


  Scenario Outline: Moonr eval function call
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the FuncCall element
    
    Examples:
      | literal        |
      | foo(whatever)  |
      | foo(arg1,arg2) |
      | foo()          |

  Scenario Outline: Moonr eval postfix expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr postfix_expr
    Then i get the PostfixExpr element
    
    Examples:
      | literal |
      | foo--   |
      | foo++   |

  Scenario Outline: Moonr eval unary expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr unary_expr
    Then i get the UnaryExpr element
    
    Examples:
      | literal         |
      | delete whatever |
      | typeof whatever |

  Scenario Outline: Moonr eval multiple expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr additive_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal |
      | ad*-c   |
      | a*b/c   |

  Scenario Outline: Moonr eval additive expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr shift_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal |
      | a-c     |
      | a*b-c   |
      | a*-b+c  |
      | 1+1*2   |

  Scenario Outline: Moonr eval bitwise shift expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr relational_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal |
      | 1<<1+2  |
      | a<<2+1  |
      | a>>c    |

  Scenario Outline: Moonr eval relational expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr equality_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal        |
      | 1< 2           |
      | a<2+1          |
      | a>c            |
      | a instanceof 1 |

  Scenario Outline: Moonr eval equality expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr bitand_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal   |
      | 1< 2 == 2 |
      | a != 1    |

  Scenario Outline: Moonr eval binand expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr bitxor_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal  |
      | 1< 2 & 2 |
      | a &1     |

  Scenario Outline: Moonr eval binxor expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr bitor_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal  |
      | 1< 2 ^ 2 |
      | a ^1     |

  Scenario: Moonr eval binor expr
    Given a js literal "1<2|2" is provided
    When i parse it using moonr logical_and_expr
    Then i get the BinaryExpr element
    
  Scenario Outline: Moonr eval logical and expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr logical_or_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal   |
      | 1< 2 && 2 |
      | a &&1     |

  Scenario: Moonr eval logical or expr
    Given a js literal "1<2||2" is provided
    When i parse it using moonr cond_expr
    Then i get the BinaryExpr element

  Scenario: Moonr eval ternary expr
    Given a js literal "1<2?1:2" is provided
    When i parse it using moonr cond_expr
    Then i get the TernaryExpr element

  Scenario Outline: Moonr eval assignment expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr assignment_expr
    Then i get the AssignExpr element
    
    Examples:
      | literal |
      | a = 1   |
      | a=b+1   |

  Scenario Outline: Moonr eval  expr list
    Given a js literal "<literal>" is provided
    When i parse it using moonr expr_state
    Then i get the Expr element
    
    Examples:
      | literal    |
      | a = 1,1<2  |
      | c-a, a=b+1 |

  Scenario Outline: Moonr eval function expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr member_expr
    Then i get the FuncExpr element
    
    Examples:
      | literal           |
      | function (a) {b;} |
      | function a(b){c;} |






    

  
    



      
