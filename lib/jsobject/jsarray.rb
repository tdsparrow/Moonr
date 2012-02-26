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
    internal_property :prototype, JSNull.inst
    
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
      @properties[:length] = JSDataDescriptor.new(@array.size,
                                                  true,
                                                  false,
                                                  false)
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
      args.each_with_index do |a,i|
        desc = JSDataDescriptor.new(a, true, true, true)
        @array << desc
        @properties[i] = desc
      end
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

    def base_def_own_property(name, desc, to_throw)
      current = get_own_property(name)
      reject if current.undefined? and not extensible

      if current.undefined? and extensible
        if desc.is_generic? or desc.is_data?
          @properties[name] = desc.copy
        else
          @properties[name] = desc.copy
        end
        return true
      end

      return true if desc.select {|v| not v.nil?}.empty?
      return true if desc == current

      unless current.configurable
        reject if desc.configurable
        reject if current.configurable == ! desc.configurable
      end
    end
    
    def def_own_property(name, desc, to_throw)

      old_len_desc = get_own_property(name)
      old_len = old_len_desc.value

      if name == :length or name == "length"
        return base_def_own_property(name, desc, to_throw)  if (desc.value.nil?)

        new_len_desc = desc.dup
        new_len = desc.value
        # todo TypeError check
        new_len_desc.value = new_len

        return base_def_own_property(name, new_len_desc, to_throw) if new_len >= old_len

        reject unless old_len_desc.writable

        if new_len_desc.writable.nil? or
            new_len_desc.writable
          new_writable = true
        else
          defer(:writable, false)
          new_writable = false
          new_len_desc.writable = true
        end

        succeed = base_def_own_property(prop, new_len_desc, to_throw)
        return succeed unless succeed

        while ( new_len < old_len )
          old_len = old_len.pred
          del_succeed = delete(old_len, false)

          if not del_succeed
            new_len_desc.value = old_len + 1
            new_len_desc.writable = false unless new_writable
            base_def_own_property(:length, new_len_desc, false)
            reject
          end
        end

        base_def_own_property(:length, JSDataDescriptor.new(nil, false), false) unless new_writable

        return ture
      elsif is_index?(name)
        index = name.to_i
        reject if index >= old_len and not old_len_desc.writable
        succeed = base_def_own_property(name, desc, false)
        reject unless succeed

        if index >= old_len
          old_len_desc.value = index + 1
          base_def_own_property(:length, old_len_desc, false)
        end
        return true
      end

      return base_def_own_property(name, desc, to_throw)
      
    end

    def get_property(prop)
      prop = get_own_property(prop)
      return prop unless prop.undefined?

      proto = prototype
      return JSUndefined.inst if proto.null?
      return proto.get_property(prop)
    end

    def get(prop)

      desc = get_property(prop)
      return JSUndefined.inst if desc.undefined?
      return desc.value if desc.is_data?

      getter = desc.get
      return JSUndefined.inst if getter.undefined?

      return getter.call(self)
    end

    def put(prop, value, to_throw)
      raise TypeError if not can_put(prop) and to_throw
      return if not can_put(prop)

      own_desc = get_own_property(prop)
      if own_desc.is_data?
        value_desc = JSDataDescriptor.new(value)
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
      return JSUndefined.inst unless @properties[prop]
      return @properties[prop]
    end
  end
end
