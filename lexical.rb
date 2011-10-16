# -*- coding: utf-8 -*-
require 'parslet'

module Moonr
  module Lexical
    include Parslet
    
    rule(:source_char) { any }

    # lexical rule
    rule(:inputelementdiv) { whitespace | line_term | comment | token | divpunctuator }
    rule(:inputelementregexp) { whitespace | line_term | comment | token | regular_expr_literal }


    
    # lineterminator
    # \u000A <LF>
    # \u000D <CR>
    # \u2028 <LS>
    # \u2029 <PS>  
    rule(:line_term) { str("\u000A") | str("\u000D") | str("\u2028") | str("\u2029") }

    #LineTerminatorSequence :: 
    #  <LF>
    #  <CR> [lookahead 􏰀 <LF> ] 
    #  <LS>
    #  <PS>
    #  <CR> <LF>
    rule(:line_term_seq) {
      str("\u000A") |
      str("\u2028") |
      str("\u2029") |
      str("\u000D") >> str("\u000A").maybe
    }

    # whitespace
    # simply handle of code
    # WhiteSpace ::one of
    #    <TAB> <VT> <FF> <SP> <NBSP> <BOM> <USP>
    rule(:whitespace) { str("\u0009") | str("\u000B") | str("\u000c") | str("\u0020") | str("\u00A0") | str("\uFEFF") }
    rule(:ws) { ( whitespace | line_term | comment ).repeat }
    rule(:nl_ws) { ( whitespace | sline_comment | multilinecomment_nl ).repeat }
    rule(:eof) { any.absent? }


    # comment
    rule(:comment) { multilinecomment | sline_comment }


    #MultiLineComment ::
    #  /* MultiLineCommentCharsopt */
    
    #MultiLineCommentChars ::
    #  MultiLineNotAsteriskChar MultiLineCommentCharsopt 
    # * PostAsteriskCommentCharsopt

    #PostAsteriskCommentChars ::
    #  MultiLineNotForwardSlashOrAsteriskChar MultiLineCommentCharsopt 
    #  * PostAsteriskCommentCharsopt

    #MultiLineNotAsteriskChar :: 
    #  SourceCharacter but not *
    
    #MultiLineNotForwardSlashOrAsteriskChar :: 
    # SourceCharacter but not one of / or *

    rule(:multilinecomment) { str('/*') >> multilinecomment_char.repeat >> str('*/') }
    rule(:multilinecomment_char) {
      str('*/').absent? >> source_char
    }
    rule(:multilinecomment_nl) { str('/*') >> multilinecomment_char_nl.repeat >> str('*/') }
    rule(:multilinecomment_char_nl) { str('*/').absent? >> line_term.absent? >> source_char }

    
    # rule(:multilinecomment_chars) {  
    #   str("*") >> postasterisk_commentchars? |
    #   multiline_not_asteriskchar >> multilinecomment_chars?  

    # }
    # rule(:multilinecomment_chars?) { multilinecommentchars.maybe }

    # rule(:postasterisk_commentchars) { 
    #   str("*") >> postasterisk_commentchars? |
    #   multiline_not_forwardslash_or_asteriskchar >> multilinecommentchars? 
    # }
    # rule(:multiline_not_asteriskchar) { str("*").absent? >> source_char }
    # rule(:multiline_not_forwardslash_or_asteriskchar) { match('[/*]').absent? >> sourcecharacter }

    #SingleLineComment ::
    #  // SingleLineCommentCharsopt
    rule(:sline_comment) { str("//") >> sline_commentchars? }

    #SingleLineCommentChars ::
    #  SingleLineCommentChar SingleLineCommentCharsopt
    rule(:sline_commentchars) { sline_commentchar >> sline_commentchars? }
    rule(:sline_commentchar) { line_term.absent? >> source_char }
    rule(:sline_commentchars?) { sline_commentchars.maybe }

    
    # token
    rule(:token) { identifier_name | punctuator | numericliteral | stringliteral }
    rule(:identifier) { ( reservedword >> identifier_start.absent? ).absent? >> identifier_name }
    rule(:identifier_name) { identifier_start  >> identifier_part.repeat }
    rule(:identifier_start) { unicodeletter | str('$') | str('_') | str('\\') >> unicode_escape_seq }
    
    rule(:identifier_part) { 
      identifier_start |
      unicode_combiningmark |
      unicodedigit |
      unicode_connectorpunctuation |
      str("\u200c") | # <ZWNJ>
      str("\u200d")  # <ZWJ>
    }

    # different from spec
    rule(:unicodeletter) { match(/\p{Lu}/) | match(/\p{Ll}/) | match(/\p{Lt}/) | match(/\p{Lm}/) | match(/\p{Lo}/) | match(/\p{Nl}/) }
    rule(:unicode_combiningmark) { match(/\p{Mn}/) | match(/\p{Mc}/) }
    rule(:unicodedigit) { match(/\p{Nd}/) }
    rule(:unicode_connectorpunctuation) { match(/\p{Pc}/) }
    
    rule(:reservedword) { keyword | future_reservedword | nullliteral | booleanliteral }
    rule(:keyword) { oneof %w{break do instanceof typeof case else new var catch finally return void continue for switch while debugger function this with default if throw delete in try} }

    # missed some reserved for strict mode
    rule(:future_reservedword) { oneof %w{class enum extends super const export import} }
    
    rule(:punctuator) { oneof %w| { } ( ) [ ] . ; , < > <= >= == != === !== + - * % ++ -- << >> >>> & ^ ! ~ &&  ? : = += -= *= %= <<= >>= >>>= &=  ^= | | str("|") | str("||") | str("|=") }
    rule(:divpunctuator) { oneof %w{ / /= } }

    rule(:literal) { nullliteral | booleanliteral | numeric_literal | string_literal | regular_expr_literal }

    rule(:nullliteral) { str("null") }
    rule(:booleanliteral) { str("true") | str("false") }

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
      str('+') >> str_unsigned_decimal_literal |
      str('-') >> str_unsigned_decimal_literal |
      str_unsigned_decimal_literal 
    }
    rule(:str_unsigned_decimal_literal) {
      str('Infinity') |
      str('.') >> decimal_digits >> exponent_part? |
      decimal_digits >> str('.') >> decimal_digits? >> exponent_part? |
      decimal_digits >> exponent_part?
    }



    # Numberic literal
    rule(:numeric_literal) { hex_integer_literal | decimal_literal }
    rule(:decimal_literal) { 
      str('.') >> decimal_digits >> exponent_part? |
      decimalinteger_literal >> str('.') >> decimal_digits? >> exponent_part? |
      decimalinteger_literal >> exponent_part?
    }
    rule(:decimalinteger_literal) { str('0') | nonzero_digit >> decimal_digits? }
    rule(:decimal_digits) { decimal_digit.repeat }
    rule(:decimal_digits?) { decimal_digits.maybe }
    rule(:decimal_digit) { oneof %w{ 0 1 2 3 4 5 6 7 8 9 } }
    rule(:nonzero_digit) { oneof %w{ 1 2 3 4 5 6 7 8 9 } }
    rule(:exponent_part) { exponent_indicator >> signed_integer }
    rule(:exponent_part?) { exponent_part.maybe }
    rule(:exponent_indicator) { oneof %w{ e E } }
    rule(:signed_integer) { 
      decimal_digits |
      str('+') >> decimal_digits |
      str('-') >> decimal_digits
    }
    rule(:hex_integer_literal) { 
      ( str('0x')  | str('0X')  ) >> hex_digit.repeat(1)
    }
    rule(:hex_digit) { oneof %w{ 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F} }

    
    rule(:string_literal) { 
      str("'") >> singlestring_chars? >> str("'") |
      str('"') >> doublestring_chars? >> str('"') 
      
    }
    rule(:doublestring_chars) { doublestring_char.repeat }
    rule(:doublestring_chars?) { doublestring_chars.maybe }
    rule(:singlestring_chars) { singlestring_char.repeat }
    rule(:singlestring_chars?) { singlestring_chars.maybe }
    rule(:doublestring_char) {
      ( str('"') | str("\\") | line_term ).absent? >> source_char |
      str("\\") >> escape_seq |
      line_continuation
    }
    
    rule(:singlestring_char) {
      ( str("'") | str('\\') | line_term ).absent? >> source_char |
      str('\\') >> escape_seq |
      line_continuation
    }
    rule(:line_continuation) { str("\\") >> line_term_seq }
    rule(:escape_seq) { 
      char_escape_seq |
      str('0')  >> decimal_digit.absent? |
      hex_escape_seq |
      unicode_escape_seq 
    }
    
    rule(:char_escape_seq) { single_escape_char | non_escape_char }
    rule(:single_escape_char) { oneof(%w{  b f n r t v }) | str("\\") | str("'") | str('"') }
    rule(:non_escape_char) { source_char >> escape_char.absent? | line_term } 
    rule(:escape_char) { 
      single_escape_char |
      decimal_digit |
      str('x') |
      str('u')
    }
    rule(:hex_escape_seq) { str('x') >> hex_digit.repeat(2,2) }
    rule(:unicode_escape_seq) { str('u') >> hex_digit.repeat(4,4) }

    # Regular expression
    rule(:regular_expr_literal) { str("/") >> regular_expr_body >> str("/") >> regular_expr_flags }
    rule(:regular_expr_body) { regular_expr_first_char >> regular_expr_chars }
    rule(:regular_expr_chars) { regular_expr_char.repeat }
    rule(:regular_expr_first_char) {
      (oneof(%w{ * / [ }) | str("\\") ).absent? >>  regular_expr_non_term |
      regular_expr_backslash_seq |
      regular_expr_class
    }
    rule(:regular_expr_char) {
      (oneof(%w{ / [ } ) | str("\\") ).absent? >>  regular_expr_non_term |
      regular_expr_backslash_seq |
      regular_expr_class
    }
    rule(:regular_expr_backslash_seq) { str('\\') >> regular_expr_non_term }
    rule(:regular_expr_non_term) { line_term.absent? >> source_char }
    rule(:regular_expr_class) { str('[') >> regular_expr_class_chars >> str(']') }
    rule(:regular_expr_class_chars) { regular_expr_class_char.repeat }
    rule(:regular_expr_class_char) { ( str("]") | str("\\") ).absent? >> regular_expr_non_term | regular_expr_backslash_seq }

    # missing one condition: could be empty
    rule(:regular_expr_flags) { identifier_part.repeat }


  end  
end
