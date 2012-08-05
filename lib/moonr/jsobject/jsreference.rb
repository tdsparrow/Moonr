module Moonr
  class JSReference
    self.extend Property

    internal_property :base, nil
    internal_property :name, ""
    internal_property :strict, nil

    def initialize base, name, strict = false
      @internal_properties = self.class.create_internal_properties
      self.base = base
      self.name = name
      self.strict = strict
    end

    def get_value
      raise ReferenceError if is_unresolvable_ref?

      if is_property?
        # todo
        # missed the special get function in #8.7.1
        if not has_primitive_base?
          return base.get name
        end

      else
        # env rec
        base.get_binding_value name, strict
      end
    end

    def put_value(val)
      raise ReferenceError if is_unresolvable_ref? # miss strict check

      if is_property?
        if has_primitive_base?
          throw 
        else
          base.put name, val, strict
        end
      else
        base.set_mutable_binding name, val, strict
      end
      
    end

    def is_property?
      base.is_a? JSBaseObject or has_primitive_base?
    end

    def has_primitive_base?
      base.is_a? JSString or base.is_a? JSNumber or base.is_a? JSBoolean
    end

    def is_unresolvable_ref?
      base.nil?
    end

    def is_strict_ref?
      strict == true
    end

    def to_s
      "This is a refernce to value: #{get_value.to_s}"
    end
  end
end
