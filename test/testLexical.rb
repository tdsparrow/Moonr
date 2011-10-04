# -*- coding: utf-8 -*-
require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'lexical'
require 'util'

class TestLexical < Parslet::Parser
  include Moonr::Lexical
  include Moonr::Util
  
end
  
  
class TC_Regexp < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestLexical.new
  end

  def test_reg_parse 
    @parser.regular_expr_body.parse('whatever')
    
    @parser.regular_expr_literal.parse("/w/")
    @parser.regular_expr_literal.parse("/wh[ever]/g")
  end

  def test_identifier 
    @parser.identifier_name.parse 'abc'
  end

  def test_num_parse
    @parser.str_decimal_literal.parse('+123')
    @parser.decimal_digits.parse('123')
    @parser.str_numeric_literal.parse('123')
    @parser.whitespace.parse(' ')
    
    @parser.string_numeric_literal.parse(' 123')

    @parser.string_numeric_literal.parse(' +123')
    @parser.string_numeric_literal.parse(' +123.3e12')
  end

  def test_comment 
    @parser.comment.parse('// whatever')
  end
end
