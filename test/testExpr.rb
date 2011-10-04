require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'expression'
require 'util'

class TestExpr < Parslet::Parser
  include Moonr::Expression
  include Moonr::Util
  
  rule(:function_expr) { str('nosuchthing') }
  root :primary_expr
end


class TC_Expr < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestExpr.new
  end

  def test_num_parse
    @parser.literal.parse('123')
  end

  def test_additive_expr
    @parser.additive_expr.parse('123 + 2  ')
    @parser.additive_expr.parse('123 + +2  ')
    @parser.additive_expr.parse('123+2*3')
  end

  def test_shift_expr
    @parser.shift_expr.parse('2<<12')
    @parser.shift_expr.parse('1+2<<12')
    @parser.shift_expr.parse('1+2 << 12 << 1>> 1 >>>2')
  end

  def test_call_expr
    @parser.call_expr.parse('foo(1)')
    @parser.lh_side_expr.parse('foo(1)')
    @parser.cond_expr.parse('foo(1)')
  end
end
