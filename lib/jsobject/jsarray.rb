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
    end

    def get(prop)
    end

    def put(prop, value, to_throw)
    end

    def get_own_property(prop)
    end
  end
end
