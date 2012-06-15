require 'moonr/parser/syntax'
require 'moonr/parser/transform/transform'
require 'moonr/parser/ast'


module Moonr
  module Parser
    class SyntaxParser < Parslet::Parser
      include Statement
      include Util
      root :program

      def initialize
        _ws = self.ws
        Parslet::Atoms::DSL.send(:define_method, :_ws ){
          _ws
        }
      end
    end

    @parser = SyntaxParser.new
    @trans = Transform.new
    
    def self.parse js
      parse_partial :root, js
    end

    def self.parse_partial elem, js
      @trans.apply(@parser.send(elem).parse js)
    end

  end
end
Parslet::Atoms::DSL.class_eval {
  def +(parslet)
    self >> _ws >> parslet
  end
}

