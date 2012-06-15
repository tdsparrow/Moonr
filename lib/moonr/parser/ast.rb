class Moonr::ASTElem
  def initialize arg
    @arg = arg
  end
end

Dir["#{File.dirname(__FILE__)}/ast/*.rb"].each { |f| require "#{f}" }



