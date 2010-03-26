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
    before do
      @class = Class.new do
        include AsyncRack::AsyncCallback::SimpleWrapper
        class << self
          attr_accessor :instance
        end
        def initialize(app = nil)
          self.class.instance = self
          @app = app
        end
        def call(env)
          setup_async env
          @app.call(env) + 5
        end
      end
    end

    it "runs #call again on async callback, replacing app" do
      middleware = @class.new false, proc { throw :async }
      catch(:async) do
        middleware.call "async.callback" => proc { |x| x + 10 }
        raise "should not get here"
      end
      middleware.env["async.callback"].call(0).should == 15
    end

    it "plays well with Rack::Builder" do
      klass = @class
      app = Rack::Builder.app do
        use klass
        run lambda { |env|
          return 37 if @threw
          @threw = true
          throw :async
        }
      end
      catch(:async) do
        app.call "async.callback" => proc { |x| x + 10 }
        raise "should not get here"
      end
      @class.instance.env["async.callback"].call(0).should == 15
      @class.instance.env["async.callback"].call(10).should == 25
      result = app.call "async.callback" => proc { |x| x + 10 }
      result.should == 42
    end
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
