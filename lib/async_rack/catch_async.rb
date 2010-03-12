require 'rack'
module AsyncRack
  class CatchAsync
    Rack::CatchAsync = self unless defined? Rack::CatchAsync

    def initialize(app, async_response = [-1, {}, []])
      @app, @async_response = app, async_response
    end

    def call(env)
      response = @async_response
      catch(:async) { response = @app.call env }
      response
    end
  end
end
