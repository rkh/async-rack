require File.expand_path("../../spec_helper", __FILE__)

describe AsyncRack::AsyncCallback do
  it "wraps rack middleware by replacing it" do
    namespace = Module.new
    namespace.const_set :Foo, Class.new
    non_async_middleware = namespace::Foo
    namespace::Foo.should == non_async_middleware
    async_middleware = Class.new AsyncRack::AsyncCallback(:Foo, namespace)
    namespace::Foo.should_not == non_async_middleware
    namespace::Foo.should == async_middleware
    AsyncRack::AsyncCallback(:Foo, namespace).should == non_async_middleware
  end

  describe :InheritanceHook do
  end
  
  describe :SimpleWrapper do
  end
  
  describe :Mixin do
  end
end
