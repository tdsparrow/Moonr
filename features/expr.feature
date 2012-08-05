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
    Then i get the ObjectLiteral element
    When i eval it with execution context "var a=1, b=2;"
    Then i get a JSObject result
    And i get "<result>" with property "<name>"

    Examples:
      | literal                      | size | name | result    |
      | { x: 'x',}                   |    1 | x    | x         |
      | {}                           |    0 |      | undefined |
      | { x: 'x', b: b }             |    2 | b    | 2         |
      | { x: 'x', get my_a() { a;} } |    2 | x    | x         |
      | { x:'x', set my_a(a) { 2;} } |    2 | x    | x         |
      | { 1: 1}                      |    1 | 1    | 1         |



  Scenario Outline: Moonr eval property accessor
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the PropertyAccessor element
    When i eval it with execution context "var a=1, b=2;"
    Then i get the reference with <value> of <property>

    Examples:
      | literal               | value | property |
      | {a: 'x', b: 'y'}['a'] | x     | a        |
      | {a: 'x', b: 'y'}.b    | y     | b        |


  Scenario Outline: Moonr eval new operator
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the NewOp element
    When i eval it with execution context "var foo = function(a){return 1};"
    Then i get a JSObject result
    
    Examples:
      | literal                     | 
      | new function() { return 1 } | 
      | new foo(whatever)           | 


  Scenario Outline: Moonr eval function call
    Given a js literal "<literal>" is provided
    When i parse it using moonr lh_side_expr
    Then i get the FuncCall element
    When i eval it with execution context "var foo = function(a,b) { return 1 };var bar = function(){return foo};"
    Then i get the result "<result>"
    
    Examples:
      | literal        | result |
      | foo(whatever)  |      1 |
      | foo(arg1,arg2) |      1 |
      | foo()          |      1 |
      | bar()()        |      1 |


  Scenario Outline: Moonr eval postfix expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr postfix_expr
    Then i get the PostfixExpr element
    When i eval it with execution context "var foo = 1;"
    Then i get the result "<result>"
    And i get the "<expectation>" from "<assertion>"
    
    Examples:
      | literal | result | assertion | expectation        |
      | foo--   |      1 | foo       | (normal, 0, empty) |
      | foo++   |      1 | foo       | (normal, 2, empty) |


  Scenario Outline: Moonr eval unary expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr unary_expr
    Then i get the UnaryExpr element
    When i eval it with execution context "<context>"
    Then i get the result "<result>"
    
    # add delete succeed case
    Examples:
      | literal         | result    | context                            |
      | delete whatever | false     | var whatever = 'string';           |
      | typeof whatever | string    | var whatever = 'string';           |
      | void whatever   | undefined | var whatever = 'string';           |
      | typeof func     | function  | var func = function() { return 0;} |
      | typeof 1        | number    | var whatever = 'string';           |
      | ++i             | 2         | var i = 1;                         |
      | --i             | 0         | var i = 1;                         |
      | +i              | -1        | var i = -1;                        |
      | -i              | -1        | var i = 1;                         |
      | ~i              | -2        | var i = 1;                         |
      | !i              | false     | var i = true;                      |


  Scenario Outline: Moonr eval multiple expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr additive_expr
    Then i get the BinaryExpr element
    When i eval it with execution context "<context>"
    Then i get the result "<result>"
    
    # missed remainder
    Examples:
      | literal |             result | context                  |
      | ad*-c   |                 -2 | var ad = 1; var c = 2;   |
      | a*b/c   | 0.6666666666666666 | var a = 1, b = 2, c = 3; |


  Scenario Outline: Moonr eval additive expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr shift_expr
    Then i get the BinaryExpr element
    
    Examples:
      | literal | result | context                    |
      | a-c     |     -1 | var a = 1, c = 2;          |
      | a*b-c   |   -0.8 | var a = 1, b = 0.2, c = 1; |
      | a*-b+c  |     -3 | var a = 2, b = 3, c = 3;   |
      | 1+1*2   |      3 | var a = 1;                 |


  Scenario Outline: Moonr eval bitwise shift expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr relational_expr
    Then i get the BinaryExpr element
    When i eval it with execution context "<context>"
    Then i get the result "<result>"

    # todo >>>
    Examples:
      | literal | result | context             |
      | 1<<1+2  |      8 | var a = 1;          |
      | a<<2+1  |     16 | var a = 2;          |
      | a>>c    |      4 | var a = 18, c = 2;  |
      | a>>c    |     -5 | var a = -18, c = 2; |
      #  | a>>>c   |        | var a = -18, c = 2; |


  Scenario Outline: Moonr eval relational expr
    Given a js literal "<literal>" is provided
    When i parse it using moonr equality_expr
    Then i get the BinaryExpr element
    When i eval it with execution context "<context>"
    Then i get the result "<result>"
    
    Examples:
      | literal        | result | context    |
      | 1< 2           | true   | var a = 1; |
      | a<2+1          |        |            |
      | a>c            |        |            |
      | a instanceof 1 |        |            |

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
    When i eval it with execution context "var a=1, b=2, c=3;"
    Then i get a JSFunction result

    
    Examples:
      | literal             |
      | function (a,c) {b;} |
      | function a(b){c;}   |






    

  
    



      
