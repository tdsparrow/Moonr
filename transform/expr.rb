module Moonr
  class Expr < Parslet::Transform

    # Array initialiser
    rule(:elision => simple(:e) ) { JSArray.new(Array.new(e.to_s.count(','))) }
    rule(:elisions => simple(:e) ) { e.nil? ?JSArray.new([]):e }
    
    rule(:elisions => simple(:e), :assignment => simple(:a) ) {  e.nil? ? JSArray.new([a]): e << a }
    
    rule(:array_literal => sequence(:a) ) {  a.inject(:+) }
    rule(:array_literal => simple(:a) ) { a }

    # Object initialiser
    rule(:lcb => simple(:l), :rcb => simple(:r) ) { JSObject.new }
    rule(:property_name => simple(:name), :assignment_expr => simple(:value) ) do
      JSPropIdentifier.new(name, JSDataDescriptor.new(value, true, true, true))
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
  end
end
