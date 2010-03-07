require "rack/logger"

module AsyncRack
  class Logger < AsyncCallback(:Logger)
    def async_callback(result)
      @logger.close
      super
    end

    def call(env)
      @logger = ::Logger.new(env['rack.errors'])
      @logger.level = @level
      env['rack.logger'] = @logger
      @app.call(env) # could throw :async
      @logger.close
    rescue Exception => error # does not get triggered by throwing :async (ensure does)
      @logger.close
      raise error
    end
  end
end
