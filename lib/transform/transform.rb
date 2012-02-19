require 'transform/expr'
require 'transform/literal'

module Moonr
  class Transform
    def initialize
      @trans = [ Literal.new, Expr.new ]
    end

    def apply(ast)
      @trans.inject(ast) { |res, t|p res; t.apply res }
    end
  end
end
