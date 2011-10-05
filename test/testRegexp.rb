# -*- coding: utf-8 -*-
require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'lexical'
require 'util'

class TestReg < Parslet::Parser
  include Moonr::Lexical
  include Moonr::Util
  
  root :regular_expr_literal

end
  
  
class TC_Regexp < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestReg.new
  end

  def test_reg_parse 
    @parser.regular_expr_body.parse('whatever')
    
    @parser.parse("/w/")
    @parser.parse("/wh[ever]/g")
  end
end
