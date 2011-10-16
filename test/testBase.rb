require 'parslet'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'util'
require 'expression'
require 'statement'

class TestBase < Parslet::Parser
  include Moonr::Util
  include Moonr::Expression
  include Moonr::Statement

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
end
