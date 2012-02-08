module Moonr
  class Literal < Parslet::Transform

    rule(:numeric_literal => simple(:n)) { n }

    rule(:hex_integer => simple(:n)) { Integer(n) }
    
    rule(:decimal_integer => simple(:n) ) { n.to_i }
    rule(:decimal_integer => simple(:n), :exponent => simple(:e)) { n.to_i * ((e.nil?)?1:10**e) }
    
    rule(:signed_integer => simple(:n) ) { n.to_i }
    
    rule(:decimal_digits => simple(:d), :exponent => simple(:e)) { ('.'+d).to_f * ((e.nil?)?1:10**e) }
    rule(:decimal_integer => simple(:i), :decimal_digits => simple(:d), :exponent => simple(:e) ) { (i+'.'+d).to_f * ((e.nil?)?1:10**e) }
    
    rule(:bool => simple(:b) ) { b == 'true' }

    rule(:chars => simple(:s) ) { s }
    rule(:chars => sequence(:c) ) { c.join }
    rule(:non_escape => simple(:c) ) { c.to_s }
    rule(:char => simple(:c) ) { c }
    rule(:single_escape => simple(:c) ) { str = "\"\\#{c}\""; eval(str) }
    rule(:unicode => simple(:c) ) { str = "\"\\u#{c}\""; eval(str) }
    rule(:line_cont) { "" }
    rule(:hex_escape => simple(:c) ) { str = "\"\\x#{c}\""; eval(str) }
  end
end
