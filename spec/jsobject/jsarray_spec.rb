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
      arr.get(0).should == 'a'
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
      pending "prototype not implemented and initial length not checked"
    end
  end

  context "#get" do
    it "should support argument length" do
      @array.get(:length).should == 0
    end

    it "should return undefined on property other then length for new Array object" do
      @array.get(:what).should == Moonr::Null
    end
  end
  
  context "#put" do
    it "should support length" do
      @array.put :length, 2, false
      @array.get(:length).should == 2
    end
  end

  context "invariant of relation between length and indexed members" do
    it "should increase length when new element added" do
      @array.def_own_property "3", Moonr::PropDescriptor.new(:value => 3), false
      @array.get("3").should == 3
      @array.get(:length).should == 4
    end

    it "should delete indexed elements when shrink length" do
      @array.def_own_property "3", Moonr::PropDescriptor.new(:value => 8, :configurable => true), false
      @array.put :length, 2, false
      @array.get("3").should == Moonr::Null
    end
  end

  context "#def_own_property" do
    it "should be able to add new indexed element" do
      @array.def_own_property("10", Moonr::PropDescriptor.new(:value => 10), false).should be_true
      @array.get("10").should == 10
    end
  end

end
