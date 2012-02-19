# -*- coding: utf-8 -*-
require 'parslet'
require 'token'
require 'util'

module Moonr
  module Number
    include Parslet
    include Util
    include Token
    
    # string numeric literal
    # the origin grammar production
    # StringNumericLiteral :::
    #    StrWhiteSpace(opt)
    #    StrWhiteSpace(opt) StrNumericLiteral StrWhiteSpace(opt)
    # parslet cannot handle common left prefix "StrWhiteSpace(opt)" here
    rule(:string_numeric_literal) { 
      # str_whitespace.maybe | 
      str_whitespace.maybe >> str_numeric_literal.maybe  >> str_whitespace.maybe
    }
    rule(:str_whitespace) { str_whitespace_char.repeat(1) }
    rule(:str_whitespace_char) { whitespace | line_term }
    rule(:str_numeric_literal) { str_decimal_literal | hex_integer_literal }
    rule(:str_decimal_literal) { 
      str_unsigned_decimal_literal |
      str("+") >> str_unsigned_decimal_literal |
      str("-") >> str_unsigned_decimal_literal
    }
    rule(:str_unsigned_decimal_literal) {
      str('Infinity') |
      decimal_digits >> str('.') >> decimal_digits? >> exponent_part? |
      str('.') >> decimal_digits >> exponent_part? |
      decimal_digits >> exponent_part?
    }

    # digits
    rule(:decimal_digits) { decimal_digit.repeat(1) }
    rule(:decimal_digits?) { decimal_digits.maybe }
    rule(:decimal_digit) { oneof %w{ 0 1 2 3 4 5 6 7 8 9 } }
    rule(:exponent_part) { exponent_indicator >> signed_integer }
    rule(:exponent_part?) { exponent_part.maybe }
    rule(:exponent_indicator) { oneof %w{ e E } }
    rule(:signed_integer) { 
      decimal_digits |
      str('+') >> decimal_digits |
      str('-') >> decimal_digits
    }
    rule(:hex_integer_literal) { 
      str('0x') >> hex_digit |
      str('0X') >> hex_digit |
      hex_integer_literal >> hex_digit
    }
    rule(:hex_digit) { oneof %w{ 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F} }


  end
end
