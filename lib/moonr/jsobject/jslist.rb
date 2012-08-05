module Moonr
  class JSList
    extend Forwardable
    include Enumerable

    def_delegator :@array, :<<, :<<
    def_delegator :@array, :each, :each

    def initialize arr = []
      @array = arr
    end
    def self.empty
      self.new []
    end
  end
end
