# -*- coding: utf-16 -*-
require 'parslet'

class Parser < Parslet::Parser
  rule(:string) { str("\s") }
  root(:string)
end


Parser.new.parse("whatever")
