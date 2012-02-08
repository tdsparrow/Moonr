module Moonr
  class JSArray 
    def initialize(size = 0)
      @array = Array.new size
    end

    def size
      @array.size
    end

    alias :length :size
    def to_arr()
      @array
    end
    
    def +(arr)
      JSArray.new(@array + arr.to_arr)
    end

    def <<(entry)
      JSArray.new(@array << entry)
    end
  end
end
