require 'parslet'
require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'util'
require 'token'

class TestUtil < Parslet::Parser
  include Moonr::Util

  rule(:atom) { str('a') }
  rule(:post_atom) { atom + postfix( %w{ b c >> }, str('d') ).repeat(1) }
  
end


class TC_Util < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestUtil.new
  end

  def test_postfix
    @parser.post_atom.parse('abdcdbdcdcd>>d')
  end
end
