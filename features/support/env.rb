$: << File.expand_path("../../../", __FILE__)

require 'rspec'
require 'rspec-expectations'
require 'moonr'

module MoonrHelper
  def parse(syntax)
    parser = Moonr::Parser.new.send( syntax.empty? ? :root : syntax.lstrip )
    @result = Moonr::Result.new(parser.parse @input)
    @eval = nil
  end

  def input_str(js)
    @input = js
  end

  def input_file(js)
    @input = File.open js
  end

  def result
    return @eval unless @eval.nil?
    @eval = @result.eval
  end
end

World(MoonrHelper)

