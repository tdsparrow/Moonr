require 'thor'
$: << File.expand_path("../", __FILE__)
require 'moonr'

class Runner < Thor
  desc "rule NAME", "specify root rule for javascript parse"
  def rule(rule)
    parser = Moonr::Parser.new.send(rule.to_sym)
    input = STDIN.readline.strip
    p input
    begin
      p parser.parse(input)
    rescue Parslet::ParseFailed => err
      puts err
      puts err, parser.error_tree
    end
  end
end

Runner.start
