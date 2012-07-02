require 'simplecov'
SimpleCov.start

require 'rspec'
require 'rspec-expectations'
require 'moonr'

Moonr::Log.level = :debug
module MoonrHelper
  def parse(syntax)
   # parser = Moonr::Parser.new.send( syntax.empty? ? :root : syntax.lstrip )
    @js_result = Moonr::Parser.parse_partial(syntax.empty? ? :root : syntax.lstrip, @js_input)
  end

  def input_str(js)
    @js_input = js
  end

  def input_file(js)
    @js_input = File.open js
  end

  def result
    @js_result
  end

  def jseval(env)
    @js_result = result.jseval(env)
  end

  def globalenv()
    @js_globalenv ||= Moonr::GlobalContext.new
  end


end

World(MoonrHelper)

