module Moonr
  class JSReference
    self.extend Property

    internal_property :base, nil
    internal_property :name, ""
    internal_property :strict, nil

    def initialize base, name
      @internal_properties = self.class.create_internal_properties
      self.base = base
      self.name = name
    end

    def get_value
      raise ReferenceError if is_unresolvable_ref?

      if is_property?
        # todo
        # missed the special get function in #8.7.1
        if not has_primitive_base?
          return base.get name
        end
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
  end
end
