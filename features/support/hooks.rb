require 'pp'

After('@eval') do |scenario|
  if scenario.failed?
    pp result
  end
end
