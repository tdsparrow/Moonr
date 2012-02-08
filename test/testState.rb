require 'test/unit'
$:.unshift File.dirname(File.expand_path(__FILE__))+ "/../"
$:.unshift File.dirname(File.expand_path(__FILE__))
require 'testBase'

class TestState < TestBase
  
  root :statement
end


class TC_State < Test::Unit::TestCase
  def initialize name
    @__name__ = name
    @parser = TestState.new
  end

  def test_default_clause
    @parser.default_clause.parse('default : 1+2;')
  end

  def test_case_clause
    @parser.case_clause.parse('case 1 : 1+2;')
  end

  def test_with_state
    @parser.with_state.parse('with (1+2) 1+3;')
  end

  def test_expr_state
    @parser.expr_state.parse('foo(1);')
    @parser.function_expr.parse('function foo() { print("a"); }')
  end
  
  def test_var_state 
    @parser.variable_state.parse 'var a = [Catch, CatchReturn];'
    @parser.variable_state.parse 'var x = 0x123456789ABCD / 0x2000000000000;'
  end

  def test_try_state
    p @parser.expr.parse %Q|r = f()|
    @parser.try_state.parse %Q|try { r = f(); } catch (o) { return g(o); }finally { return 2; }|
    @parser.try_state.parse %Q|try {
      if (i == iter) gc();
    } finally {
      if (i == iter) gc();
    }|

    @parser.try_state.parse %Q|try {
    throw 1;
  } catch (o) {
    a.push(o);
    try {
      throw 2;
    } catch (o) {
      a.push(o);
    }
    a.push(o);
  }|
  end

  def test_for_state
    @parser.program.parse  %Q|for (var n in a) {
  var c = a[n];
  assertEquals(1, c(function() { return 1; }));
  assertEquals('bar', c(function() { return 'bar'; }));
  assertEquals(1, c(function () { throw 1; }, function (x) { return x; }));
  assertEquals('bar', c(function () { throw 'bar'; }, function (x) { return x; }));
}|

    @parser.iteration_state.parse %Q|for (var i = 1; i <= iter; i++) {
    try {
      if (i == iter) gc();
    } finally {
      if (i == iter) gc();
    }
  }|

    @parser.iteration_state.parse %Q|for(i = 0; i < a.length; i++) result.push(a[i]);|
    end

  def test_while_state 
    @parser.block.parse %Q|{
      x++;
      if (false) return -1;
      cont = false;
      continue;

    }|

    @parser.statement.parse %Q|{
    try {
      x++;
      if (false) return -1;
      cont = false;
      continue;
    } catch (o) {
      x--;
    }
  }|
      
    @parser.iteration_state.parse %Q|while (cont) {
    try {
      x++;
      if (false) return -1;
      cont = false;
      continue;
    } catch (o) {
      x--;
    }
  }|
  end

  def test_call_expr 
    @parser.expr.parse "assertEquals(2, (function() { try { throw {}; } catch(e) {} finally { return 2; } })())"

    @parser.function_body.parse %Q|var iter = 1000000;
for (var i = 1; i <= iter; i++) {
  }|

    @parser.expr.parse %Q|(function () {
  var iter = 1000000;
  for (var i = 1; i <= iter; i++) {
    try {
      if (i == iter) gc();
    } finally {
      if (i == iter) gc();
    }
  }
})()|

  end

  def test_func_decl
    @parser.function_declaration.parse %Q|function trycatch(a) {
  var o;
  try {
    throw 1;
  } catch (o) {
    a.push(o);
    try {
      throw 2;
    } catch (o) {
      a.push(o);
    }
    a.push(o);
  }}|

    @parser.function_declaration.parse %Q|function continue_from_catch(x) {
  x--;
  var cont = true;
  while (cont) {
    try {
      x++;
      if (false) return -1;
      cont = false;
      continue;
    } catch (o) {
      x--;
    }
  }
  return x;
}|
  end
  
  def test_for_ASI 
    @parser.program.parse %Q|var a = [Catch, CatchReturn]
for (var n in a) {
  var c = a[n];
  }|
    
    @parser.nl_ws.parse " "
    @parser.se.parse ";"
    @parser.nl_se.parse " ;"
    @parser.continue_state.parse "continue;"
  end


  def test_switch_state
    @parser.switch_state.parse %Q[switch (event_data.script().compilationType()) {
          case Debug.ScriptCompilationType.Host:
            host_compilations++;
            break;
          case Debug.ScriptCompilationType.Eval:
            eval_compilations++;
            break;
          default: balbal();
        }]
  end

  def test_json
    puts '"\b\f\n\r\t\"\u2028\/\\"'
    puts '"\/"'
    @parser.string_literal.parse '"\/"'
    @parser.string_literal.parse '"\b\f\n\r\t\"\u2028\/\\"'
  end
end
