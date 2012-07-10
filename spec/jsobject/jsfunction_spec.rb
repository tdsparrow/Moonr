require 'spec_helper'

describe Moonr::Function do
  def function 
    Moonr::Function.new 
  end

  def func_proto_obj 
    function.get(:prototype)
  end

  it "should has internal property class of value 'Function'" do
    function.clazz.should == 'Function'
  end

  it "should have a Function prototype object" do
    function.get(:prototype).clazz.should == 'Function'
  end

  it "should have a length property" do
    function.get(:length).should == 1
  end

  it "should has internal property prototype of value Function.prototype" do
    function.prototype.should == Moonr::FunctionPrototype
  end

  it "should be able to call" do
    function.should respond_to :call
    function.call('p1,p2', 'return 1').should be_a Moonr::JSFunction
  end

  context "prototype" do
    it "should return undefined invoked with any arguments" do
      func_proto_obj.call.should == Moonr::Undefined
      func_proto_obj.call(1,'22').should == Moonr::Undefined
    end

    it "should has Object.prototype object as [[prototype]] internal property" do
      func_proto_obj.prototype.should == Moonr::ObjectPrototype
    end

    it "should has 1 as initial value of [[Extensible]] internal property" do
      func_proto_obj.extensible.should == true
    end

    it "should not has own valueOf property" do
      func_proto_obj.get_own_property(:valueOf).should be Moonr::Undefined
    end

    it "should has 0 length property" do
      func_proto_obj.get(:length).should == 0
    end

    it "should has JSFunction asj constructor property" do
      func_proto_obj.get(:constructor).should == Moonr::JSFunction
    end

    it "should has method toString()" do
      pending "function string presentation"
    end

    it "should has method apply()" do
      func_proto_obj.get(:apply).should be_is_a(Moonr::JSFunction)
    end
  end

  context "initialize" do
    it "should create a new function" do
      func = new_func(nil, "p1", "p2", "return 1")
      func.should be_is_a(Moonr::JSFunction)      

      func.prototype.should == func_proto_obj

      func.get(:length).should == 2

      func.get(:prototype).should be_is_a Moonr::JSObject

      func.extensible.should be_true

      func.code.should be_a Moonr::Sources

      func = new_func(nil, "p1", "p2, p3", "return 1")
      func.get(:length).should == 3

      pending "Strict is not implemented yet"
    end

  end

end
