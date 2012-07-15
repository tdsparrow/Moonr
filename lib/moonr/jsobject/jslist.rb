module Moonr
  class JSList
    extend Forwardable
    def_delegator :@array, :<<, :<<

    def initialize arr = []
      @array = arr
    end
    def self.empty
      self.new []
    end
  end
end
