require 'moonr/parser/transform/literal'
require 'moonr/parser/transform/statement'

module Moonr
  class Transform
    def initialize
      @trans = [ Literal.new,  Stms.new ]
    end

    def apply(ast)
      @trans.inject(ast) { |res, t| t.apply res }
    end
  end
end
