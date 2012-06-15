require 'spec_helper'

describe Moonr::JSFunction do
  def new_func *args
    Moonr::JSFunction.new *args
  end

  def func_proto_obj 
    Moonr::JSFunction.get(:prototype)
  end

  it "should has internal property class of value 'Function'" do
    Moonr::JSFunction.clazz.should == 'Function'
  end

  it "should have a Function prototype object" do
    Moonr::JSFunction.get(:prototype).clazz.should == 'Function'
  end

  it "should have a length property" do
    Moonr::JSFunction.get(:length).should == 1
  end

  it "should has internal property prototype of value Function.prototype" do
    Moonr::JSFunction.prototype.should == Moonr::FunctionPrototype
  end

  it "should be able to call" do
    Moonr::JSFunction.should be_respond_to :call
    Moonr::JSFunction.call('p1,p2', 'return 1').should be_a Moonr::JSFunction
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
      func_proto_obj.get_own_property(:valueOf).should be_nil
    end

    it "should has 0 length property" do
      func_proto_obj.get(:length).should == 0
    end

    it "should has JSFunction as constructor property" do
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

      func.code.should be_is_a Moonr::JSSources

      func = new_func(nil, "p1", "p2, p3", "return 1")
      func.get(:length).should == 3

      pending "Strict is not implemented yet"
    end

    it "should create a new function to be callable" do

    end

  end

end


