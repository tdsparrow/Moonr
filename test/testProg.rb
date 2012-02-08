require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
require 'statement'
require 'util'

class TestProg < Parslet::Parser
  def initialize
    _ws = self.ws
    Parslet::Atoms::DSL.send( :define_method, :_ws ){
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
  
  root :program


end


class TC_Prog < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestProg.new
  end

  Dir.glob("**/*.js") { |file|
    p "Creating case for #{file}"
    define_method("test_" + File.basename(file)) {
      p "Running case #{@__name__}"
      @parser.parse(File.open(file))
    }
    
  }

end
