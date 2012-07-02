@eval
Feature: Moonr eval js statement

  Scenario Outline: Moonr eval block statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the BlockStat element

    Examples:
      | literal  |
      | {a}      |
      | { a-1;b} |
      | {}       |


  Scenario Outline: Moonr eval variable statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr
    Then i get the Sources element
    When i eval it with global execution context
    Then i get the result "(normal, empty, empty)"
    
    Examples:
      | literal   |
      | var a=1;  |
      | var a, b; |

  Scenario Outline: Moonr eval expression statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the ExprStat element
    When i eval it with execution context "<context>"    
    Then i get the result "<result>"

    Examples:
      | literal | context          | result             |
      | a+ b;   | var a=1;var b=1; | (normal, 2, empty) |
      | a+b+1;  | var a=1;var b=2; | (normal, 4, empty) |


  Scenario Outline: Moonr eval expression statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the ExprStat element

    Examples:
      | literal   |
      | a+ b; |

  Scenario Outline: Moonr eval expression statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the IfStat element

    Examples:
        | literal          |
        | if(a<b) c;else d |

  Scenario Outline: Moonr eval do while statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the DoWhileStat element

    Examples:
        | literal            |
        | do { a+1;}while(a) |

  Scenario Outline: Moonr eval while statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the WhileStat element

    Examples:
        | literal        |
        | while(a){ a+1} |

  Scenario Outline: Moonr eval for statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the ForStat element

    Examples:
        | literal               |
        | for(a=1;b=2;c=3){d=4} |

  Scenario Outline: Moonr eval continue statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the ContinueStat element

    Examples:
        | literal      |
        | continue;    |
        | continue id; |

  Scenario Outline: Moonr eval break statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the BreakStat element

    Examples:
        | literal   |
        | break;    |
        | break id; |


  Scenario Outline: Moonr eval return statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the ReturnStat element

    Examples:
        | literal   |
        | return;    |
        | return id; |

  Scenario Outline: Moonr eval with statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the WithStat element

    Examples:
        | literal      |
        | with(a) {b} |


  Scenario Outline: Moonr eval switch statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the SwitchStat element

    Examples:
        | literal                                                      |
        | switch (a) { case b: c;case d: e;default:f;}                 |
        | switch (a+1) { case b: c; case e: f;g;}                      |
        | switch (a+1) { case b: c;default: d; case e: f;g; case h:j;} |
        | switch (a+1) { case b: c;default: d;d; case e: f;g;}         |


  Scenario Outline: Moonr eval label statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the LabelStat element

    Examples:
        | literal |
        | id: a;  |

  Scenario Outline: Moonr eval throw statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the ThrowStat element

    Examples:
        | literal      |
        | throw 1;     |
        | throw a +1 ; |
        | throw a,b;   |

  Scenario Outline: Moonr eval try statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the TryStat element

    Examples:
        | literal                              |
        | try {a;} catch (b) {c;}              |
        | try {a;} finally {b;}                |
        | try {a;} catch (b) {c;} finally {d;} |


  Scenario: Moonr eval debugger statement
    Given a js literal "debugger;" is provided
    When i parse it using moonr statement
    Then i get the DebugStat element

  Scenario Outline: Moonr eval function decl statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr source_element
    Then i get the FuncDeclStat element

    Examples:
       | literal           |
       | function a(b){c;} |

  Scenario Outline: Moonr eval program
    Given a js literal "<literal>" is provided
    When i parse it using moonr program
    Then i get the Sources element

    Examples:
       | literal           |
       | function a(b){c;} |


  Scenario Outline: Moonr eval strict/non strict program
    Given a js literal "<literal>" is provided
    When i parse it using moonr program
    Then i get the Sources element
    And send message "strict?" get "<strict>"
    When i eval it with global execution context
    Then i get the result "<result>"

    
    Examples:
      | literal               | result                      | strict |
      | 'use strict';         | (normal, use strict, empty) | true   |
      | 'asdfa';'use strict'; | (normal, use strict, empty) | true   |














        

