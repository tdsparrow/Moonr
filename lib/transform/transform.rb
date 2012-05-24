require 'transform/expr'
require 'transform/literal'
require 'transform/Statement'

module Moonr
  class Transform
    def initialize
      @trans = [ Literal.new, Expr.new, Stms.new ]
    end

    def apply(ast)
      @trans.inject(ast) { |res, t| Log.info res; t.apply res }
    end
  end
end
