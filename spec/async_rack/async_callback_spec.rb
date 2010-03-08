require File.expand_path("../../spec_helper", __FILE__)

describe AsyncRack::AsyncCallback do
  before do
    @namespace = Module.new
    @namespace.const_set :Foo, Class.new
  end

  it "wraps rack middleware by replacing it" do
    non_async_middleware = @namespace::Foo
    @namespace::Foo.should == non_async_middleware
    async_middleware = Class.new AsyncRack::AsyncCallback(:Foo, @namespace)
    @namespace::Foo.should_not == non_async_middleware
    @namespace::Foo.should == async_middleware
    AsyncRack::AsyncCallback(:Foo, @namespace).should == non_async_middleware
  end

  describe :InheritanceHook do
    it "alows aliasing subclasses automatically" do
      @namespace::Foo.extend AsyncRack::AsyncCallback::InheritanceHook
      @namespace::Foo.alias_subclass :Bar, @namespace
      subclass = Class.new(@namespace::Foo)
      @namespace::Bar.should == subclass
    end
  end

  describe :SimpleWrapper do
  end

  describe :Mixin do
    it "wrapps async.callback" do
      @middleware = proc { |env| env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, ['OK']] }
      @middleware.extend AsyncRack::AsyncCallback::Mixin
      @middleware.should_receive(:async_callback)
      @middleware.call "async.callback" => proc { }
    end
  end
end
