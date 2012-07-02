require 'spec_helper'

describe Moonr::Parser do
  def parse elem, js
    @result = Moonr::Parser.parse_partial elem, js
  end

  after(:each) do
    if example.exception
      p @result
    end
  end

  it "should parse a function body to JSSources" do
    parse(:function_body, "return 1").should be_a Moonr::JSSources
  end
end
