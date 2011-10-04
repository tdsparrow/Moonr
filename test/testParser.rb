# -*- coding: utf-8 -*-
require 'test/unit'
require 'iconv'
require '../parser.rb'

class TC_Javascript < Test::Unit::TestCase
  def test_lexical_parse
    parser = Javascript.new
    parser.parse_js('whetever')
  end
end
