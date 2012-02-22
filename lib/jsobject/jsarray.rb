module Moonr
  class JSArray
    @properties = []
    @internal_properties = []

    class << self
      attr_reader :properties
      attr_reader :internal_properties
    end
    
    def self.property(prop)
      @properties << prop
    end

    def self.internal_property(prop, value)
      @internal_properties << [prop, value]
      define_method(prop) do
        @internal_properties[prop]
      end
    end

    internal_property :clazz, "Array"
    internal_property :extensible, true
    property :length
    
    def initialize(*args)
      @properties = {}
      @internal_properties = {}
      self.class.properties.each { |prop| @properties[prop] = nil }
      self.class.internal_properties.each { |prop,value|  @internal_properties[prop] = value }

      create_arr_with_num(*args) || create_arr_with_elem(*args)

      update_length
    end

    def update_length
      @properties[:length] = JSDataDescriptor.new(:value => @array.size,
                                                  :writable => true,
                                                  :enumerable => false,
                                                  :configurable => false)
    end
    
    def size
      @array.size
    end

    def create_arr_with_num(*args)
      if args.length == 1 and args.first.is_a?(Numeric)
        @array = Array.new args.first
      end
    end

    def create_arr_with_elem(*args)
      @array = Array.new
      args.each { |a| @array << a }
    end
    
    def to_arr()
      @array
    end
    
    def +(arr)
      JSArray.new(@array + arr.to_arr)
    end

    def <<(entry)
      JSArray.new(@array << entry)
    end

    def def_own_property(name, desc, to_throw)
      @properties[name.to_sym] = desc
      p @properties
    end

    def get_property(prop)
      prop = get_own_property(prop)
      return prop unless prop.undefined?

      proto = prototype
      return Undefined.new if proto.null?
      return proto.get_property(prop)
    end
    
    def get(prop)
      desc = get_property(prop)
      return Undefined.new if desc.undefined?
      return desc.value if desc.is_data?

      getter = desc.get
      return undefined.new if getter.undefined?

      return getter.call(self)
    end

    def put(prop, value, to_throw)
      raise TypeError if not can_put(prop) and to_throw
      return if not can_put(prop)

      own_desc = get_own_property(prop)
      p own_desc
      if own_desc.is_data?
        value_desc = JSDataDescriptor.new(:value=> value)
        def_own_property(prop, value_desc, to_throw)
        return
      end

      desc = get_property(prop)

      if desc.is_accessor?
        desc.set self, value
      elsif
        new_desc = JSDataDescriptor.new(value, true, true, true)
        def_own_property(prop.new_desc, to_throw)
      end
        
    end

    def can_put(prop)
      desc = get_own_property(prop)

      p desc

      if not desc.undefined?
        if desc.is_accessor?
          return false if desc.set.undefined?
          return true
        end

        return desc.writable
      end

      proto = prototype
      return extensible if proto.null?

      inherited = proto.get_property(prop)
      return extensible if inherited.undefined?

      if inherited.is_accessor?
        return false if inherited.set.undefined?
        return true
      else
        return false if extensible
        return inherited.writable
      end
    end

    def get_own_property(prop)
      return Undefined.new unless @properties[prop]
      return @properties[prop].dup
    end
  end
end
