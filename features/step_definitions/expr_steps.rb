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

Then /^i get the proc$/ do 
  result.should be_a Moonr::NewOp
end

When /^i eval it with global env$/ do
end
