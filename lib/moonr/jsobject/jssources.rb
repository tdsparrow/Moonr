module Moonr
  class JSSources
    def initialize arr
      @stats = arr
    end

    def self.empty
      @empty ||= JSSources.new []
    end
  end
end
