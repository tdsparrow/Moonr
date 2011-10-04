require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'expression'
require 'statement'
require 'util'

class TestState < Parslet::Parser
  def initialize
    _ws = self.ws
    Parslet::Atoms::DSL.send(:define_method, :_ws ){
      _ws
    }

    Parslet::Atoms::DSL.class_eval {
      def +(parslet)
        self >> _ws >> parslet
      end
    }
    
  end

  include Moonr::Statement
  include Moonr::Expression
  include Moonr::Util
  
  root :statement
end


class TC_State < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestState.new
  end

  def test_default_clause
    @parser.default_clause.parse('default : 1+2;')
  end

  def test_case_clause
    @parser.case_clause.parse('case 1 : 1+2;')
  end

  def test_with_state
    @parser.with_state.parse('with (1+2) 1+3;')
  end

  def test_expr_state
    @parser.expr_state.parse('foo(1);')
    @parser.function_expr.parse('function foo() { print("a"); }')
  end
  
  def test_var_state 
    @parser.variable_state.parse('var a = [Catch, CatchReturn];')
  end

  def test_call_state
    @parser.cond_expr.parse  %Q|c(function () { throw 'bar'; }, function (x) { return x; })|
    @parser.program.parse  %Q|assertEquals('bar', c(function () { throw 'bar'; }, function (x) { return x; }));|
  end

end
