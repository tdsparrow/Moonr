class Moonr::ASTElem
  def self.register_op(op, method)
    @handler ||= {}
    @handler[op] = method.to_proc
  end

  def self.handler; @handler; end
    
  def initialize(arg={})
    @arg = arg
  end

  def method_missing(sym, *args, &block) 
    @arg[sym]
  end

  def eval_op(context, op, *args)
    self.class.handler[op.to_sym].call(self, context, *args)
  end
    
end

Dir["#{File.dirname(__FILE__)}/ast/*.rb"].each { |f| require "#{f}" }



