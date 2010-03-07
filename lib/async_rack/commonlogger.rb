require "rack/commonlogger"

module AsyncRack
  class CommonLogger < AsyncCallback(:CommonLogger)
    def async_callback(result)
      status, header, body = result
      header = Rack::Utils::HeaderHash.new header
      log env, status, header, @began_at
      super [status, header, body]
    end

    def call(env)
      @began_at = Time.now
      super
    end
  end
end
