# -*- coding: utf-8 -*-

module Moonr
  module Util
    def oneof(arr)
      arr.map{|a| str(a) }.inject(:|) 
    end
    
    def postfix( arr, post, tag=nil )
      arr.map do |a| 
        if tag
          str(a).as(tag) + post 
        else
          str(a) + post
        end
      end.inject(:|)
    end
  
  end
end



