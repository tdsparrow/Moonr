Given /^a js file "([^"]*)" is provided$/ do |js|
  input_file js
end

When /^i parse it using moonr(\s*\w*)?$/ do |syntax|
  parse syntax
end

Then /^i get the result$/ do
  @result.should be_succeed
end
