module Moonr

  ObjectPrototype = JSBaseObject.new {
    def prototype
      Null
    end

    def clazz
      'Object'
    end

    def extensible
      true
    end

  }

  class JSObject < JSBaseObject
    extend Objective

    internal_property :clazz, "Object"
    internal_property :prototype, JSObject.new
    internal_property :extensible, true
    
    def initialize(&block)
      super()

      instance_eval(&block) if block_given?
    end

    def size
      @properties.size
    end

    def add_property(prop)
      prev = get_own_property(prop.name)

      if not prev.undefined?
        # todo check the condition for strict code
        p 'not good'
        raise SyntaxError if prev.is_data? and prop.desc.is_accessor?
        raise SyntaxError if prev.is_accessor? and prop.desc.is_data?
        raise SyntaxError if prev.is_accessor? and prop.desc.is_accessor? and [prev,prop.desc].all?{|d| not d.get.nil? } or [prev, prop.desc].all?{|d| not d.set.nil? }
      end

      def_own_property(prop.name.to_sym, prop.desc, false)
    end

    # constructor's internal properties
    def self.prototype
      FunctionPrototype
    end


    singletonclass = class << self; extend Property; self; end
    # Object constructor's property, not Object objects'
    singletonclass.property :prototype, PropDescriptor.new(:value => ObjectPrototype)

    @properties = singletonclass.create_properties

  end

  ObjectPrototype.def_own_property(:constructor, PropDescriptor.new(:value => JSObject), false)
end
