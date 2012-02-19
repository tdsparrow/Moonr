module Moonr
  class Undefined
  end

  class JSObject
    def initialize(&block)
      @data = {}
      instance_eval(&block) if block_given?
    end

    def def_own_property(name, desc, to_throw)
      @data[name] = desc
    end

    def get_own_property(name)
      @data[name] || Undefined
    end
    
    def size
      @data.size
    end

    def add_property(prop)
      prev = get_own_property(prop.name)
      case prev
      # todo strict mode code c        
      when JSDataDescriptor
        raise SyntaxError if prop.desc === JSAccessorDescriptor
        
      when JSAccessorDescriptor
        raise SyntaxError if prop.desc === JSDataDescriptor
        raise SyntaxError if prop.desc === JSAccessorDescriptor and [prev,prop.desc].all?{|d| not d.get.nil? } or [prev, prop.desc].all?{|d| not d.set.nil? }
      end if not prev === Undefined

      def_own_property(prop.name, prop.desc, false)

    end
  end
end
