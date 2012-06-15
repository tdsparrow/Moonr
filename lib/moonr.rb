require 'moonr/parser'
require 'moonr/jsobject'
require 'moonr/env'
require 'mixlib/log'

module Moonr
  class Log; extend Mixlib::Log; end
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
  
  # class Parser < Parslet::Parser
  #   include Statement
  #   include Expression
  #   include Util
  #   root :program

  #   def initialize
  #     _ws = self.ws
  #     Parslet::Atoms::DSL.send(:define_method, :_ws ){
  #       _ws
  #     }
  #   end

  #   def parsejs(js)
  #     Result.new(parse File.open(js))
  #   end
  # end

end

class String
  def get_value
    self
  end
end



