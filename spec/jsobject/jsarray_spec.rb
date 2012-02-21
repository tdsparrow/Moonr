require 'spec_helper'

describe Moonr::JSArray do
  before do
    @array = Moonr::JSArray.new 
  end
  
  context "#initialize" do
    it "should create an empty array without paramenter" do
      @array.size.should == 0
    end

    it "should create an array with number of element" do
      arr = Moonr::JSArray.new 2
      arr.size.should == 2
    end

    it "should create an array with one non-number paramenter" do
      arr = Moonr::JSArray.new 'a'
      arr.size.should == 1
      pending "hold on for array subscription operation"
    end

    it "should create an array with a list of elements" do
      arr = Moonr::JSArray.new 'a', 'b', 'c'
      arr.size.should == 3
    end
    
    it "should raise RangeError on a large number" do
      pending "type check later"
    end

    it "should create a object with default array internal property" do
      @array.clazz.should == "Array"
      @array.extensible.should == true
      end
  end

  context "#get" do
    it "should support argument length" do
      @array.get(:length).value.should == 0
    end
  end
  
  context "#put" do
    it "should support length" do
      @array.put :length, 1, false
    end
  end

  context "#get_own_property" do
    it "should return undefined on property other then length for new Array object" do
      @array.get_own_property :what
    end

    it "should get the value on length property" do
    end
  end
end
