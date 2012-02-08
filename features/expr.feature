Feature: Moonr eval js expression

  Scenario Outline: Moonr eval array initialiser
    Given a js literal "<literal>" is provided
    When i parse it using moonr
    Then i get the array with size <size>
    
    Examples:
      | literal       | size |
      | [ , , ]       |    2 |
      | [ , , ,]      |    3 |
      | [ a,b,,]      |    3 |
      | [ a, b, c, ,] |    4 |
      | [ a,,  , b ]  |    4 |
      | [,]           |    1 |
      | [ab]          |    1 |
      | [    ]        |    0 |


  Scenario Outline: Moonr eval object initialiser
    Given a js literal "<literal>" is provided
    When i parse it using moonr primary_expr
    Then i get the object with <size> properites

    Examples:
      | literal            | size |
      | { a: 'x'}          |    1 |
      | {}                 |    0 |
      | { a: 'x', b: 'y' } |    2 |






      
      
