module Moonr
  class VariableStat < ASTElem
    def append another
      @list ||= []
      @list << another
      self
    end
  end
end
