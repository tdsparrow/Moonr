@eval
Feature: Moonr eval js expression

  Scenario Outline: Moonr eval function declaration
    Given a js literal "<literal>" is provided
    When i parse it using moonr
    Then i get the FuncDef element
    
    Examples:
      | literal                     | size |
      | function foo() { return 1 } |    0 |





      
