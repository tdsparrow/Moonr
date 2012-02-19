require 'parslet'
require 'statement'
require 'expression'
require 'transform/transform'
require 'jsobject'
require 'util'

module Moonr
  class Result
    def initialize ast
      @ast = ast
    end
    
    def succeed?
      true
    end

    def eval
      Transform.new.apply @ast
    end
    
  end
  
  class Parser < Parslet::Parser
    include Statement
    include Expression
    include Util
    root :program

    def initialize
      _ws = self.ws
      Parslet::Atoms::DSL.send(:define_method, :_ws ){
        _ws
      }
    end

    def parsejs(js)
      Result.new(parse File.open(js))
    end
  end
end

Parslet::Atoms::DSL.class_eval {
  def +(parslet)
    self >> _ws >> parslet
  end
}
