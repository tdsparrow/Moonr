describe Moonr::JSObject do
  context "prototype" do
    it "should has null as [[Prototype]] internal property" do
      Moonr::JSObject.get(:prototype).prototype.should == Moonr::Null
    end

    it "should has built-in Object constructor as property constructor" do
      Moonr::JSObject.get(:prototype).get(:constructor).should == Moonr::JSObject
    end
  end
end
