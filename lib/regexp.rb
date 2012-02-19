# -*- coding: utf-8 -*-

require 'parslet'
require 'token'
require 'util'

module Moonr
  module Regexp 
    include Parslet
    include Token
    include Util

    # Regular expression
    rule(:regular_expression_literal) { str("/") >> regular_expression_body >> str("/") >> regular_expression_flags }
    rule(:regular_expression_body) { regular_expression_first_char >> regular_expression_chars }
    rule(:regular_expression_chars) { regular_expression_char.repeat }
    rule(:regular_expression_first_char) {
      (oneof(%w{ * / [ }) | str("\\") ).absent? >>  regular_expression_non_term |
      regular_expression_backslash_seq |
      regular_expression_class
    }
    rule(:regular_expression_char) {
      (oneof(%w{ / [ } ) | str("\\") ).absent? >>  regular_expression_non_term |
      regular_expression_backslash_seq |
      regular_expression_class
    }
    rule(:regular_expression_backslash_seq) { str('\\') >> regular_expression_non_term }
    rule(:regular_expression_non_term) { line_term.absent? >> source_char }
    rule(:regular_expression_class) { str('[') >> regular_expression_class_chars >> str(']') }
    rule(:regular_expression_class_chars) { regular_expression_class_char.repeat }
    rule(:regular_expression_class_char) { ( str("]") | str("\\") ).absent? >> regular_expression_non_term | regular_expression_backslash_seq }

    # missing one condition: could be empty
    rule(:regular_expression_flags) { identifier_part.repeat }

  end
end
