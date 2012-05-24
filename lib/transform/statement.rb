module Moonr
  class Stms < Parslet::Transform
    rule(:func_name => simple(:name), :param_list => simple(:param), :func_body => simple(:body)) do
      JSFunction.new name
    end
  end
end
 
