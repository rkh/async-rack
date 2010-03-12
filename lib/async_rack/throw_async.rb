require 'rack'

module AsyncRack
  class ThrowAsync
    Rack::ThrowAsync = self unless defined? Rack::ThrowAsync

    def initialize(app, throw_on = [-1, 0])
      @app, @throw_on = app, throw_on
    end

    def call(env)
      response = @app.call env
      throw :async if @throw_on.include? response.first
      response
    end
  end
end
