class Moonr::ASTElem
  def initialize(arg={})
    @arg = arg
  end

  def method_missing(sym, *args, &block) 
    @arg[sym]
  end
end

Dir["#{File.dirname(__FILE__)}/ast/*.rb"].each { |f| require "#{f}" }



