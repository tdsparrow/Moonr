require 'pp'

module Moonr
  class Expr < Parslet::Transform

    rule(:primary_expr => simple(:prime)) { prime }

    # Array initialiser
    rule(:elision => simple(:e) ) { e.to_s.count(',') }
    rule(:elisions => simple(:e) ) { e.nil? ? 0:e }

    # [ , , , ]
    rule(:al => simple(:al), :elisions => simple(:e), :ar => simple(:ar) ) do
      len = e.nil? ? 0:e
      JSArray.new(len)
    end
    
    rule(:elisions => simple(:e), :assignment => simple(:a) ) do
      ind = e.nil? ? 0 : e
      obj = JSArray.new(ind) 
      obj.def_own_property(ind.to_s, PropDescriptor.new(:value => a, :writable => true, :enumerable => true, :configurable => true), false )
      obj
    end

    rule(:array_literal => sequence(:a) ) do
      ret = a.inject do |total, value|
        if value.is_a? Fixnum
          total.put(:length, total.get(:length) + value, false) 
          next total
        end

        pad = value.get(:length)
        len = total.get(:length)
        total.def_own_property((pad+len-1).to_s, PropDescriptor.new(:value => value.get_at(pad-1), :writable => true, :enumerable => true, :configurable => true), false)

        total
      end
    end
    rule(:array_literal => simple(:a) ) { a }

    # Object initialiser
    rule(:lcb => simple(:l), :rcb => simple(:r) ) { JSObject.new }
    rule(:property_name => simple(:name), :assignment_expr => simple(:value) ) do
      JSPropIdentifier.new(name, PropDescriptor.new(:value => value, :writable => true, :enumerable => true, :configurable => true))
    end

    rule(:property_name => simple(:name), :get_body => simple(:get) ) do
      JSPropIdentifier.new(name, PropDescriptor.new(:get => get, :enumerable => true, :configurable => true))
    end

    rule(:property_name => simple(:name), :param_list => simple(:param), :set_body => simple(:set)) do
      JSPropIdentifier.new(name, PropDescriptor.new(:set => set, :enumerable => true, :configurable => true))
    end
    
    rule(:property_list => simple(:plist) ) do
      prop_list = plist
      JSObject.new do
        def_own_property(prop_list.name, prop_list.desc, false)
      end
    end
    
    rule(:property_list => sequence(:plist) ) do
      prop_list = plist
      JSObject.new do
        prop_list.each { |i| add_property i }
      end
    end

    rule(:obj_literal => simple(:obj)) { obj }

    # left hand side expr
    #

    # subscription
    rule(:subscription => simple(:s)) { s }
    rule(:member_expr => sequence(:mlist) ) do
      p 'finally got here'
      p mlist
      mlist.inject do |acc, subscription|
        base = acc.get_value

        # todo, update to follow ecma
        #property_name = subscription.get_value.to_s        
        property_name = subscription.to_sym
        JSBaseObject.check_coercible(base)

        # miss strict logic
        JSReference.new(base, property_name)
      end
    end

    rule(:member_expr => simple(:subject) ) { subject }

  end
end
