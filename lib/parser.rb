# -*- coding: utf-8 -*-
require 'parslet'
require 'iconv'

module Moonr

  class Javascript < Parslet::Parser
    
    # lexical rule
    rule(:inputelementdiv) { whitespace | lineterminator | comment | token | divpunctuator }
    rule(:inputelementregexp) { whitespace | lineterminator | comment | token | regularexpressionliteral }

    # whitespace
    # simply handle of code
    # WhiteSpace ::one of
    #    <TAB> <VT> <FF> <SP> <NBSP> <BOM> <USP>
    rule(:whitespace) { "\u0009" | "\u000B" | "\u000c" | "\u0020" | "\u00A0" | str("\uFEFF") }
    
    # lineterminator
    # \u000A <LF>
    # \u000D <CR>
    # \u2028 <LS>
    # \u2029 <PS>  
    rule(:lineterminator) { "\u000A" | "\u000D" | "\u2028" | "\u2029" }
    rule(:lineterminatorsequence) { "\u000A" | "\u000D" | "\u2028" | ( "\u000D" >> "\u000A" ) }

    # comment
    rule(:comment) { multilinecomment | singlelinecomment }

    rule(:multilinecomment) { str("/*") >> multilinecomment_chars? >> str("*/") }
    rule(:multilinecomment_chars) {  
      multiline_not_asteriskchar >> multilinecomment_chars?  | 
      str("*") >> postasterisk_commentchars?  
    }
    rule(:multilinecomment_chars?) { multilinecommentchars.maybe }

    rule(:postasterisk_commentchars) { 
      multiline_not_forwardslash_or_asteriskchar >> multilinecommentchars?  | 
      str("*") >> postasterisk_commentchars? 
    }
    rule(:multiline_not_asteriskchar) { str("*").absent? >> sourcecharacter }
    rule(:multiline_not_forwardslash_or_asteriskchar) { match('[/*]').absent? >> sourcecharacter }

    rule(:singlelinecomment) { str("//") >> singlelinecommentchars? }
    rule(:singlelinecommentchars) { singlelinecommentchar >> singlelinecommentchar? }
    rule(:singlelinecommentchar) { lineterminator.absent? >> sourcecharacter }
    rule(:singlelinecommentchars?) { singlelinecommentchars.maybe }

    
    # token
    rule(:token) { identifiername | punctuator | numericliteral | stringliteral }
    rule(:identifier) { reservedword.absent? >> identifiername }
    rule(:identifiername) { identifierstart | identifiername >> identifierpart }
    rule(:identifierstart) { unicodeletter | str('$') | str('_') | str('\\') >> unicode_escapesequence }
    
    rule(:identifierpart) { 
      identifierstart |
      unicode_combiningmark |
      unicodedigit |
      unicode_connectorpunctuation |
      str("\u200c") | # <ZWNJ>
      str("\u200d")  # <ZWJ>
    }

    # different from spec
    rule(:unicodeletter) { match["\p{Lu}"] | match["\p{Ll}"] | match["\p{Lt}"] | match["\p{Lm}"] | match["\p{Lo}"] | match["\p{Nl}"] }
    rule(:unicode_combiningmark) { match["\p{Mn}"] | match["\p{Mc}"] }
    rule(:unicodedigit) { match["\p{Nd}"] }
    rule(:unicode_connectorpunctuation) { match["\p{Pc}"] }
    
    rule(:reservedword) { keyword | future_reservedword | nullliteral | booleanliteral }
    rule(:keyword) { oneof %w{break do instanceof typeof case else new var catch finally return void continue for switch while debugger function this with default if throw delete in try} }

    # missed some reserved for strict mode
    rule(:future_reservedword) { oneof %w{class enum extends super const export import} }
    
    rule(:punctuator) { oneof %w| { } ( ) [ ] . ; , < > <= >= == != === !== + - * % ++ -- << >> >>> & ^ ! ~ &&  ? : = += -= *= %= <<= >>= >>>= &=  ^= | | str("|") | str("||") | str("|=") }
    rule(:divpunctuator) { oneof %w{ / /= } }

    rule(:literal) { nullliteral | booleanliteral | numericliteral | stringliteral | regularexpressionliteral }

    rule(:nullliteral) { str("null") }
    rule(:booleanliteral) { str("true") | str("false") }


    # Numberic literal
    rule(:numericliteral) { decimal_literal | hexinteger_literal }
    rule(:decimal_literal) { 
      decimalinteger_literal >> str('.') >> decimal_digits? >> exponentpart? |
      str('.') >> decimal_digits >> exponentpart? |
      decimalinteger_literal >> exponentpart?
    }
    rule(:decimalinteger_literal) { str('0') | nonzero_digit >> decimal_digits? }
    rule(:decimal_digits) { decimal_digit.repeat }
    rule(:decimal_digits?) { decimal_digits.maybe }
    rule(:decimal_digit) { oneof %w{ 0 1 2 3 4 5 6 7 8 9 } }
    rule(:nonzero_digit) { oneof %w{ 1 2 3 4 5 6 7 8 9 } }
    rule(:exponentpart) { exponent_indicator >> signed_integer }
    rule(:exponent_indicator) { oneof %w{ e E } }
    rule(:signed_integer) { 
      decimal_digits |
      str('+') >> decimal_digits |
      str('-') >> decimal_digits
    }
    rule(:hexinteger_literal) { 
      str('0x') >> hex_digit |
      str('0X') >> hex_digit |
      hexinteger_literal >> hex_digit
    }
    rule(:hex_digit) { oneof %w{ 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F} }

    
    rule(:string_literal) { str('"') >> doublestring_chars? >> str('"') | str("'") >> singlestring_chars? >> str("'") }
    rule(:doublestring_chars) { doublestring_char.repeat }
    rule(:doublestring_chars?) { doublestring_chars.maybe }
    rule(:singlestring_chars) { singlestring_char.repeat }
    rule(:singlestring_chars?) { singlestring_chars.maybe }
    rule(:doublestring_char) {
      (match['"\\'] | lineterminator).absent? >> sourcechar |
      str("\\") >> escape_seq |
      line_continuation
    }
    
    rule(:singlestring_char) {
      (match["'\\"] | line_term).absent? >> sourcechar |
      str("\\") >> escape_seq
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
    rule(:single_escape_char) { oneof %w{  b f n r t v } | str("\\") | str("'") | str('"') }
    rule(:non_escape_char) { sourcechar >> escape_char.absent? | line_term } 
    rule(:escape_char) { 
      single_escape_char |
      decimal_digit |
      str('x') |
      str('u')
    }
    rule(:hex_escape_seq) { str('x') >> hex_digit.repeat(2,2) }
    rule(:unicode_escape_seq) { str('u') >> hex_digit.repeat(4,4) }

    
    
    

    


    
    

    root :inputelementdiv

    def parse_js(str)
      parse Iconv.conv("UTF-16", "UTF-8", str)
    end

    private
    def oneof(arr)
      arr.map{|a| str(a) }.inject(:|) 
    end
  end  
end
