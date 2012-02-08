Then /^i get the array with size (\d+)$/ do |size|
  result.class.should == Moonr::JSArray
  result.length.should == size.to_i
end

Then /^i get the object with (\d+) properites$/ do |size|
  p result
  result.class.should == Moonr::JSObject
  result.size.should == size.to_i
end