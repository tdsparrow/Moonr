Then /^i get the array with size (\d+)$/ do |size|
  result.class.should == Moonr::JSArray
  result.get(:length).should == size.to_i
end

Then /^i get the object with (\d+) properites$/ do |size|
  result.class.should == Moonr::JSObject
  result.size.should == size.to_i
end

Then /^i get the reference with (\w+) of (\w+)$/ do |v, p|
  result.class.should == Moonr::JSReference
  result.get_value.should == v
end

Then /^i get the (\w+) element$/ do |elem|
  result.should be_a Moonr.const_get(elem)
end

When /^i eval it with global execution context$/ do
  jseval(globalenv)
end

Then /^i get a (\w+) result$/ do |type|
  result.should be_a Moonr.const_get(type.to_sym)
end

Then /^i get the result "([^"]*)"$/ do |value|
  result.to_s.should == value
end

Then /^send message "([^"]*)" get "([^"]*)"$/ do |method, value|
  result.send(method.to_sym).to_s.should == value
end

When /^i eval it with execution context "([^"]*)"$/ do |context|
  prog = Moonr::Parser.parse(context)
  prog.jseval(globalenv)
  jseval(globalenv)
end

Then /^i get "([^"]*)" with property "([^"]*)"$/ do |ret, prop|
  result.get(prop).to_s.should == ret
end

Then /^i get the "([^"]*)" from "([^"]*)"$/ do |expect, assert|
  prog = Moonr::Parser.parse(assert)
  prog.jseval(globalenv).to_s.should == expect
end
