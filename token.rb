# -*- coding: utf-8 -*-
require 'parslet'

module Moonr
  module Token
    include Parslet
    
    
    rule(:source_char) { any }


    # lineterminator
    # \u000A <LF>
    # \u000D <CR>
    # \u2028 <LS>
    # \u2029 <PS>  
    rule(:line_term) { str("\u000A") | str("\u000D") | str("\u2028") | str("\u2029") }

    # whitespace
    # simply handle of code
    # WhiteSpace ::one of
    #    <TAB> <VT> <FF> <SP> <NBSP> <BOM> <USP>
    rule(:whitespace) { str("\u0009") | str("\u000B") | str("\u000c") | str("\u0020") | str("\u00A0") | str("\   rule(:ws) { (whitespace | line_term).repeat }
    rule(:nl_ws) { whitespace.repeat }
   

    # token
    rule(:token) { identifiername | punctuator | numericliteral | stringliteral }
    rule(:identifier) { reservedword.absent? >> identifiername }
    rule(:identifiername) { identifierstart | identifiername >> identifierpart }
    rule(:identifierstart) { unicodeletter | str('$') | str('_') | str('\\') >> unicode_escape_seq }
    
    rule(:identifier_part) { 
      identifierstart |
      unicode_combiningmark |
      unicodedigit |
      unicode_connectorpunctuation |
      str("\u200c") | # <ZWNJ>
      str("\u200d")  # <ZWJ>
    }

    # different from spec
    rule(:unicodeletter) { match("\\p{Lu}") | match("\\p{Ll}") | match("\\p{Lt}") | match("\\p{Lm}") | match("\\p{Lo}") | match("\\p{Nl}") }
    rule(:unicode_combiningmark) { match("\\p{Mn}") | match("\\p{Mc}") }
    rule(:unicodedigit) { match("\\p{Nd}") }
    rule(:unicode_connectorpunctuation) { match("\\p{Pc}") }
    rule(:unicode_escape_seq) { str('u') >> hex_digit.repeat(4,4) }


  end
end
