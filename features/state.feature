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

  Scenario Outline: Moonr eval variable statement
    Given a js literal "<literal>" is provided
    When i parse it using moonr statement
    Then i get the VariableStat element

    Examples:
      | literal   |
      | var a;    |
      | var a, b; |

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

        

