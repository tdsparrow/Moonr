module Moonr
  class JSArray < JSBaseObject
    internal_property :clazz, "Array"
    internal_property :extensible, true
    internal_property :prototype, JSNull.inst
    
    property :length
    
    
    def initialize(*args)
      super()

      create_arr_with_num(*args) || create_arr_with_elem(*args)
      update_length
    end

    def update_length
      @properties[:length] = PropDescriptor.new( :value => @array.size,
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
      args.each_with_index do |a,i|
        desc = PropDescriptor.new(:value => a,
                                  :writable => true,
                                  :enumerable => true,
                                  :configurable => true)
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



    def reject
      raise TypeError
    end
    
    def same_value(one, other)
      return false if one.class != other.class
      return true if one.nil?
      return true if one.is_a? JSNull
      if one.is_a? Numeric
        return true if one == NaN and other == NaN
        # missed +0 != -0
        return true if one == other

        return false
      end

      if one.is_a? String
        return true if one == other
        return false
      end

      if one.is_a? FalseClass or one.is_a? TureClass
        return one == other
      end

      return one.equal? other
    end
    
    def def_own_property(name, desc, to_throw)

      old_len_desc = get_own_property(:length)
      old_len = old_len_desc.value

      if name == :length or name == "length"
        return super(name, desc, to_throw)  if (desc.value.nil?)

        new_len_desc = desc.dup
        new_len = desc.value
        # todo TypeError check
        new_len_desc.value = new_len

        return super(name, new_len_desc, to_throw) if new_len >= old_len

        reject unless old_len_desc.writable

        if new_len_desc.writable.nil? or
            new_len_desc.writable
          new_writable = true
        else
          # defer action has been taken care below
          #defer(:writable, false)
          new_writable = false
          new_len_desc.writable = true
        end

        succeed = super(name, new_len_desc, to_throw)
        return succeed unless succeed

        while ( new_len < old_len )
          old_len = old_len.pred
          del_succeed = delete(old_len.to_s, false)

          if not del_succeed
            new_len_desc.value = old_len + 1
            new_len_desc.writable = false unless new_writable
            super(:length, new_len_desc, false)
            reject
          end
        end

        super(:length, PropDescriptor.new(:writable =>false), false) unless new_writable

        return true
      elsif is_index?(name)
        index = name.to_i
        reject if index >= old_len and not old_len_desc.writable
        succeed = super(name, desc, false)
        reject unless succeed

        if index >= old_len
          old_len_desc.value = index + 1
          super(:length, old_len_desc, false)
        end
        return true
      end

      return super(name, desc, to_throw)
      
    end

    def is_index?(prop)
      prop.to_i.to_s == prop
    end
    

    def delete(prop, to_throw)
      desc = get_own_property(prop)
      Log.debug "About to delete #{prop} with value #{desc} from object"
      return true if desc.nil?

      if desc.configurable
        @properties.delete prop
        return true
      elsif to_throw
        throw TypeError
      end

      return false
    end

    def get_at(index)
      get(index.to_s)
    end
  end
end
