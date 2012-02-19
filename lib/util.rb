# -*- coding: utf-8 -*-

module Moonr
  module Util
    def oneof(arr)
      arr.map{|a| str(a) }.inject(:|) 
    end
    
    def postfix( arr, post )
      arr.map{ |a| str(a) + post }.inject(:|)
    end
  
  end
end



