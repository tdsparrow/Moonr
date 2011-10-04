require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'number'

class TestNum < Parslet::Parser
  include Moonr::Number
  
  root :string_numeric_literal
end


class TC_Number < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestNum.new
  end

  def test_num_parse
    @parser.decimal_digits.parse('123')
    @parser.str_numeric_literal.parse('123')
    @parser.parse('123')
    @parser.whitespace.parse(' ')
    
    @parser.parse(' 123')
    @parser.parse(' +123')
    @parser.parse(' +123.3e12')
  end
end
