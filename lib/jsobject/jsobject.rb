module Moonr

  class JSObject < JSBaseObject
    internal_property :clazz, "Object"
    internal_property :prototype, JSObject.new
    internal_property :extensible, true
    
    def initialize(&block)
      @properties ||= {}
      super()

      instance_eval(&block) if block_given?
    end

    def size
      @properties.size
    end

    def add_property(prop)
      prev = get_own_property(prop.name)

      if not prev.nil?
        # todo check the condition for strict code
        
        raise SyntaxError if prev.is_data? and prop.desc.is_accessor?
        raise SyntaxError if prev.is_accessor? and prop.desc.is_data?
        raise SyntaxError if prev.is_accessor? and prop.desc.is_accessor? and [prev,prop.desc].all?{|d| not d.get.nil? } or [prev, prop.desc].all?{|d| not d.set.nil? }
      end

      def_own_property(prop.name.to_sym, prop.desc, false)

    end
  end
end
