Given /^a js literal "([^"]*)" is provided/ do |js|
  input_str js
end

Then /^i get the integer (-?\d+)$/ do |res|
  result.should  == (res.to_i)
end

Then /^i get the float (.*)$/ do |res|
  result.should be_within(0.01).of(res.to_f)
end

Then /^i get the bool (true|false)$/ do |res|
  result.should  == (res == 'true')
end

Given /^a js string literal (.+) is provided$/ do |str|
  input_str str
end

Then /^i get the string (.+)$/ do |res|
  result.should == eval("\"#{res}\"")
end
