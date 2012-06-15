require 'simplecov'
SimpleCov.start

require 'rspec'
require 'rspec-expectations'
require 'moonr'

Moonr::Log.level = :debug
module MoonrHelper
  def parse(syntax)
   # parser = Moonr::Parser.new.send( syntax.empty? ? :root : syntax.lstrip )
    @result = Moonr::Parser.parse_partial(syntax.empty? ? :root : syntax.lstrip, @input)
  end

  def input_str(js)
    @input = js
  end

  def input_file(js)
    @input = File.open js
  end

  def result
    @result
  end


end

World(MoonrHelper)

