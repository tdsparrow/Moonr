module Moonr
  class JSList
    def initialize arr = []
      @array = arr
    end
    def self.empty
      self.new []
    end
  end
end
