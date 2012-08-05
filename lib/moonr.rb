require 'moonr/parser'
require 'moonr/jsobject'
require 'moonr/env'
require 'mixlib/log'
require 'ostruct'

module Moonr
  class Log; extend Mixlib::Log; end

  class ::OpenStruct
    def to_s
      "(#{type}, #{value}, #{target})"
    end
  end

  class ::Numeric
    def jseval(env, strict = false)
      self
    end
    def get_value
      self
    end
  end

  Result = ::OpenStruct

end




