Feature: Moonr can parse and eval js literal
  Moonr should comfirming ECMA262, parse and eval literal after chapter 7

  Scenario Outline: Moonr can parse integer literal

	Given a js literal "<literal>" is provided
	When i parse it using moonr literal
	Then i get the integer <result>

    Examples:
	  | literal | result |
	  | 1234	| 1234	 |
	  | 23		| 23	 |
	  | 0x12f	| 303	 |

  Scenario Outline: Moonr can parse float literal

    Given a js literal "<literal>" is provided
    When i parse it using moonr literal
	Then i get the float <result>
	  
    Examples:
	  | literal | result |
	  | 1.2 	| 1.2	 |
	  | .3		| 0.3	 |
	  | .3e-2   | 0.0003 |
	  | .2e4	| 2000	 |

  Scenario Outline: Moonr can parse boolean literal
   
    Given a js literal "<literal>" is provided
	When i parse it using moonr literal
	Then i get the bool <result>	  
	
	Examples:
	  | literal | result |	
	  | true 	| true	 |
	  | false	| false	 |

  Scenario Outline: Moonr can parse string literal
    
    Given a js string literal <literal> is provided
    When i parse it using moonr literal
    Then i get the string <result>
    
    Examples:
      | literal    | result |
      | "abc1"     | abc1   |
      | "ba\"c"    | ba\"c   |
      | "bc\z"     | bcz    |
      | "bc\bd"    | bc\bd  |
      | "a\u0045b" | aEb    |
      | 'abcd'     | abcd   |




      
